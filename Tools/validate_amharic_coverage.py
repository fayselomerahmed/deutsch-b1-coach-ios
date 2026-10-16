#!/usr/bin/env python3
"""Validate exact and composed Amharic coverage without running the iOS app."""

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "DeutschB1Coach" / "Resources" / "amharic_translations.json"
GENERATED_PATH = ROOT / "Tools" / "generated_curriculum_sources.json"
TEACHING_TEXT_PATH = ROOT / "DeutschB1Coach" / "Views" / "TeachingText.swift"


def folded(value: str) -> str:
    return value.strip().casefold()


def split_once(value: str, separator: str) -> tuple[str, str] | None:
    if separator not in value:
        return None
    return tuple(value.split(separator, 1))  # type: ignore[return-value]


def swift_dictionary_keys() -> set[str]:
    source = TEACHING_TEXT_PATH.read_text(encoding="utf-8")
    composer = source[source.index("private enum AmharicCurriculumComposer") :]
    return {
        match.group(1)
        for match in re.finditer(r'^\s*"([^"]+)":(?:\s*"|$)', composer, re.MULTILINE)
    }


def required_components(source: str) -> tuple[str, list[str]] | None:
    if source.startswith("After practicing "):
        split = split_once(
            source[len("After practicing ") :],
            ", complete this transfer mission: ",
        )
        if split:
            grammar, task = split
            return "after-practising", [grammar, task.replace(", then ", ", and ")]

    if source.startswith("The setting is "):
        match = re.fullmatch(
            r"The setting is (.+?)\. (You need .+?\.) "
            r"The active vocabulary theme is (.+?)\. (I can .+?\.) "
            r"Use (.+?) as the language tool for the task\.",
            source,
        )
        if match:
            context, complexity, _german_theme, can_do, grammar = match.groups()
            return "scenario", [context, complexity, can_do, grammar]

    if source.startswith("With "):
        match = re.fullmatch(
            r"With (.+?), you can now act in (.+?): (.+)",
            source,
        )
        if match:
            grammar, field, action = match.groups()
            return "can-do-recap", [grammar, field, f"I can {action}"]

    if source.startswith("You can recognize "):
        match = re.fullmatch(
            r"You can recognize (.+?) in a sentence such as “.+”\.",
            source,
        )
        if match:
            return "recognition-recap", [match.group(1)]

    if source.startswith("Your "):
        match = re.fullmatch(
            r"Your (.+?) review deck gained \d+ useful words from .+\.",
            source,
        )
        if match:
            return "review-deck-recap", [match.group(1)]

    if source.startswith("Write a "):
        split = split_once(source[len("Write a ") :], " for this situation: ")
        if split:
            text_type, task = split
            return "writing-prompt", [text_type, task.replace(", then ", ", and ")]

    if source.startswith("Role-play a "):
        ending = (
            " Speak in complete turns, react to the other person, "
            "and confirm the next step."
        )
        if source.endswith(ending):
            prompt = source[len("Role-play a ") : -len(ending)]
            split = split_once(prompt, " situation: ")
            if split:
                field, task = split
                return "role-play", [field, task.replace(", then ", ", and ")]

    if source.startswith("I used ") and source.endswith(" at least twice."):
        grammar = source[len("I used ") : -len(" at least twice.")]
        return "grammar-checklist", [grammar]

    if source.startswith("I used the conventions of a ") and source.endswith("."):
        text_type = source[len("I used the conventions of a ") : -1]
        return "text-type-checklist", [text_type]

    return None


def main() -> None:
    catalog = json.loads(CATALOG_PATH.read_text(encoding="utf-8"))
    generated = json.loads(GENERATED_PATH.read_text(encoding="utf-8"))
    component_keys = swift_dictionary_keys()
    known = {folded(key) for key in catalog} | {folded(key) for key in component_keys}

    failures: list[str] = []
    exact_count = 0
    composed_count = 0
    shapes: dict[str, int] = {}

    for source in generated:
        if folded(source) in known:
            exact_count += 1
            continue
        composition = required_components(source)
        if not composition:
            failures.append(f"No exact translation or composition: {source}")
            continue
        shape, components = composition
        unknown = [component for component in components if folded(component) not in known]
        if unknown:
            failures.append(
                f"Unknown {shape} component(s) {unknown!r} in: {source}"
            )
            continue
        shapes[shape] = shapes.get(shape, 0) + 1
        composed_count += 1

    if failures:
        raise SystemExit(
            f"Amharic coverage failed with {len(failures)} gap(s):\n"
            + "\n".join(failures[:40])
        )

    print(
        f"Validated {len(generated)} generated curriculum strings: "
        f"{exact_count} exact and {composed_count} locally composed."
    )
    print(
        "Composed shapes: "
        + ", ".join(f"{key}={value}" for key, value in sorted(shapes.items()))
    )


if __name__ == "__main__":
    main()
