#!/usr/bin/env python3
"""Build the bundled orientation question catalogue from official BAMF sources."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

import pdfplumber


STATE_SPECS = [
    ("BW", "Baden-Württemberg"),
    ("BY", "Bayern"),
    ("BE", "Berlin"),
    ("BB", "Brandenburg"),
    ("HB", "Bremen"),
    ("HH", "Hamburg"),
    ("HE", "Hessen"),
    ("MV", "Mecklenburg-Vorpommern"),
    ("NI", "Niedersachsen"),
    ("NW", "Nordrhein-Westfalen"),
    ("RP", "Rheinland-Pfalz"),
    ("SL", "Saarland"),
    ("SN", "Sachsen"),
    ("ST", "Sachsen-Anhalt"),
    ("SH", "Schleswig-Holstein"),
    ("TH", "Thüringen"),
]

GENERAL_IMAGE_PAGES = {
    21: 9,
    55: 21,
    70: 27,
    130: 48,
    176: 64,
    181: 67,
    187: 70,
    209: 78,
    216: 81,
    226: 85,
    235: 88,
}

CHECKBOX_PATTERN = re.compile(r"^[\u00a3\u25a1\uf0a3\uf0fe\u2610\u2611\u2612\uF0A3]\s*(.*)$")
TASK_PATTERN = re.compile(r"^Aufgabe\s+(\d+)\s*$")
FOOTER_PATTERN = re.compile(r"^Seite\s+\d+\s+von\s+191$")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pdf", type=Path, required=True)
    parser.add_argument("--answers", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--images", type=Path, required=True)
    return parser.parse_args()


def normalized_lines(text: str) -> list[str]:
    return [
        re.sub(r"\s+", " ", line.replace("\u00a0", " ")).strip()
        for line in text.splitlines()
        if line.strip()
    ]


def parse_page_questions(page_text: str) -> list[tuple[int, str, list[str]]]:
    lines = normalized_lines(page_text)
    starts = [index for index, line in enumerate(lines) if TASK_PATTERN.fullmatch(line)]
    parsed: list[tuple[int, str, list[str]]] = []

    for position, start in enumerate(starts):
        number = int(TASK_PATTERN.fullmatch(lines[start]).group(1))
        end = starts[position + 1] if position + 1 < len(starts) else len(lines)
        chunk = [line for line in lines[start + 1 : end] if not FOOTER_PATTERN.fullmatch(line)]

        prompt_lines: list[str] = []
        choices: list[str] = []
        current_choice: list[str] | None = None

        for line in chunk:
            marker = CHECKBOX_PATTERN.match(line)
            if marker:
                if current_choice is not None:
                    choices.append(" ".join(current_choice).strip())
                current_choice = [marker.group(1).strip()]
            elif current_choice is None:
                if not line.startswith("©") and not line.startswith("In Anlehnung an"):
                    prompt_lines.append(line)
            else:
                current_choice.append(line)

        if current_choice is not None:
            choices.append(" ".join(current_choice).strip())

        prompt_lines = [
            line
            for line in prompt_lines
            if line != "Bild 1 Bild 2 Bild 3 Bild 4"
        ]
        question = " ".join(prompt_lines).strip()
        question = re.sub(rf"^{number}\.\s*", "", question)
        parsed.append((number, question, choices))

    return parsed


def collect_questions(
    pages: list[pdfplumber.page.Page],
    page_numbers: range,
) -> dict[int, tuple[str, list[str]]]:
    questions: dict[int, tuple[str, list[str]]] = {}
    for page_number in page_numbers:
        text = pages[page_number - 1].extract_text() or ""
        for number, question, choices in parse_page_questions(text):
            if number in questions:
                raise ValueError(f"Duplicate question {number} on page {page_number}")
            questions[number] = (question, choices)
    return questions


def visual_image_bounds(
    page: pdfplumber.page.Page,
    *,
    preserve_credit: bool,
) -> tuple[float, float, float, float]:
    visuals = [image for image in page.images if image["x0"] > 50]
    if not visuals:
        raise ValueError(f"No visual content found on page {page.page_number}")

    left = min(image["x0"] for image in visuals) - 6
    top = min(image["top"] for image in visuals) - 6
    right = max(image["x1"] for image in visuals) + 6
    bottom = max(image["bottom"] for image in visuals) + (28 if preserve_credit else 6)
    return (
        max(0, left),
        max(0, top),
        min(page.width, right),
        min(page.height, bottom),
    )


def render_image(
    page: pdfplumber.page.Page,
    output: Path,
    *,
    preserve_credit: bool = False,
) -> None:
    image = page.crop(
        visual_image_bounds(page, preserve_credit=preserve_credit)
    ).to_image(resolution=144, antialias=True)
    image.save(output, format="PNG", optimize=True)


def make_record(
    *,
    identifier: str,
    number: int,
    question: str,
    choices: list[str],
    answer_index: int,
    scope: str,
    state_code: str | None = None,
    image_name: str | None = None,
) -> dict[str, object]:
    if not question:
        raise ValueError(f"{identifier} has no question text")
    if len(choices) != 4 or any(not choice for choice in choices):
        raise ValueError(f"{identifier} has malformed choices: {choices}")
    if answer_index not in range(4):
        raise ValueError(f"{identifier} has invalid answer index {answer_index}")

    record: dict[str, object] = {
        "id": identifier,
        "number": number,
        "scope": scope,
        "question": question,
        "choices": choices,
        "answerIndex": answer_index,
    }
    if state_code:
        record["stateCode"] = state_code
    if image_name:
        record["imageName"] = image_name
    return record


def main() -> None:
    args = parse_args()
    answers = json.loads(args.answers.read_text(encoding="utf-8"))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.images.mkdir(parents=True, exist_ok=True)

    with pdfplumber.open(args.pdf) as document:
        pages = document.pages
        general_source = collect_questions(pages, range(2, 112))
        if set(general_source) != set(range(1, 301)):
            missing = sorted(set(range(1, 301)) - set(general_source))
            raise ValueError(f"General catalogue is incomplete: {missing}")

        general_records = []
        for number in range(1, 301):
            question, choices = general_source[number]
            image_name = None
            if number in GENERAL_IMAGE_PAGES:
                image_name = f"orientation-general-{number:03d}"
                render_image(
                    pages[GENERAL_IMAGE_PAGES[number] - 1],
                    args.images / f"{image_name}.png",
                    preserve_credit=number in {55, 70, 130, 181, 216, 235},
                )
            general_records.append(
                make_record(
                    identifier=f"general-{number:03d}",
                    number=number,
                    question=question,
                    choices=choices,
                    answer_index=int(answers["general"][str(number)]),
                    scope="general",
                    image_name=image_name,
                )
            )

        state_records: dict[str, list[dict[str, object]]] = {}
        for state_index, (state_code, state_name) in enumerate(STATE_SPECS):
            first_page = 112 + state_index * 5
            state_source = collect_questions(pages, range(first_page, first_page + 5))
            if set(state_source) != set(range(1, 11)):
                missing = sorted(set(range(1, 11)) - set(state_source))
                raise ValueError(f"{state_name} catalogue is incomplete: {missing}")

            records = []
            for number in range(1, 11):
                question, choices = state_source[number]
                image_name = None
                if number in {1, 8}:
                    image_page = first_page if number == 1 else first_page + 3
                    image_name = f"orientation-{state_code.lower()}-{number:02d}"
                    render_image(
                        pages[image_page - 1],
                        args.images / f"{image_name}.png",
                    )
                records.append(
                    make_record(
                        identifier=f"{state_code.lower()}-{number:02d}",
                        number=number,
                        question=question,
                        choices=choices,
                        answer_index=int(answers["states"][state_name][str(number)]),
                        scope="state",
                        state_code=state_code,
                        image_name=image_name,
                    )
                )
            state_records[state_code] = records

    payload = {
        "version": 1,
        "source": {
            "title": "Gesamtfragenkatalog zum Test Leben in Deutschland und zum Einbürgerungstest",
            "publisher": "Bundesamt für Migration und Flüchtlinge",
            "date": "07.05.2025",
            "url": "https://www.bamf.de/SharedDocs/Anlagen/DE/Integration/Einbuergerung/gesamtfragenkatalog-lebenindeutschland.html",
        },
        "general": general_records,
        "states": state_records,
    }
    all_ids = [record["id"] for record in general_records]
    all_ids.extend(record["id"] for records in state_records.values() for record in records)
    if len(all_ids) != 460 or len(set(all_ids)) != 460:
        raise ValueError("Question identifiers are incomplete or duplicated")

    args.output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        f"Wrote {len(general_records)} general and "
        f"{sum(len(records) for records in state_records.values())} state questions"
    )


if __name__ == "__main__":
    main()
