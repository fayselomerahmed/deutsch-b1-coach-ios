#!/usr/bin/env python3
"""Populate static English meanings for every bundled vocabulary example sentence."""

from __future__ import annotations

import json
import pathlib
import time
import urllib.parse
import urllib.request


ROOT = pathlib.Path(__file__).resolve().parents[1]
VOCAB_FILES = [
    ROOT / "DeutschB1Coach" / "Resources" / f"vocab_{level}.json"
    for level in ("a1", "a2", "b1")
]
ENDPOINT = "https://translate.googleapis.com/translate_a/single"


def request_translation(sentences: list[str]) -> list[str]:
    payload = urllib.parse.urlencode(
        {
            "client": "gtx",
            "sl": "de",
            "tl": "en",
            "dt": "t",
            "q": "\n".join(sentences),
        }
    ).encode()
    request = urllib.request.Request(
        ENDPOINT,
        data=payload,
        headers={"User-Agent": "DeutschB1Coach curriculum builder"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        result = json.load(response)
    translated = "".join(segment[0] for segment in result[0]).splitlines()
    return [line.strip() for line in translated if line.strip()]


def translate(sentences: list[str]) -> list[str]:
    for attempt in range(4):
        try:
            translated = request_translation(sentences)
            if len(translated) == len(sentences):
                return translated
        except Exception:
            if attempt == 3:
                raise
        time.sleep(1.5 * (attempt + 1))

    if len(sentences) == 1:
        raise RuntimeError(f"Could not translate: {sentences[0]}")
    return [translate([sentence])[0] for sentence in sentences]


def main() -> None:
    documents = [(path, json.loads(path.read_text())) for path in VOCAB_FILES]
    pending = [
        item
        for _, entries in documents
        for item in entries
        if not item.get("exampleTranslation", "").strip()
    ]

    for start in range(0, len(pending), 20):
        batch = pending[start : start + 20]
        translations = translate([item["exampleSentence"] for item in batch])
        for item, translated in zip(batch, translations, strict=True):
            item["exampleTranslation"] = translated
        print(f"Translated {min(start + len(batch), len(pending))}/{len(pending)}")
        time.sleep(0.12)

    for path, entries in documents:
        path.write_text(json.dumps(entries, ensure_ascii=False, indent=2) + "\n")


if __name__ == "__main__":
    main()
