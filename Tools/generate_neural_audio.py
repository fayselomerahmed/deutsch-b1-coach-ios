#!/usr/bin/env python3
"""Generate offline German curriculum audio with local neural TTS models."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
import tempfile
import wave
from collections import OrderedDict
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RESOURCES = ROOT / "DeutschB1Coach" / "Resources"
OUTPUT = RESOURCES / "NeuralAudio"
PREVIEW_TEXT = "Guten Tag! Ich helfe dir, natürlich und sicher Deutsch zu sprechen."
STANDALONE_SPEAKING_TEXTS = [
    "Ich heiße Samira. Ich wohne in Hamburg und lerne Deutsch für meine Arbeit.",
    "An Werktagen stehe ich um sieben Uhr auf und fahre mit dem Bus zur Arbeit. Nach der Arbeit kaufe ich ein. Am Abend koche ich und lerne noch dreißig Minuten Deutsch.",
    "Ich wohne seit zwei Jahren in Deutschland und lerne Deutsch, weil ich die B1-Prüfung bestehen möchte. Zurzeit besuche ich einen Abendkurs. Besonders wichtig ist für mich, im Beruf sicher mit anderen sprechen zu können.",
    "Wir könnten uns am Samstag um zehn Uhr in der Bibliothek treffen. Ich bringe die Bücher mit, und du könntest Getränke besorgen. Nach zwei Stunden machen wir eine Pause. Was hältst du davon?",
    "Meiner Meinung nach sollte man in der Stadt häufiger öffentliche Verkehrsmittel benutzen. Dadurch gibt es weniger Verkehr und die Luft wird besser. Zum Beispiel fahre ich zur Arbeit mit der Bahn. Deshalb halte ich einen guten Nahverkehr für sehr wichtig.",
]
PIPER_VOICE = "de_DE-thorsten-high"
GRAMMAR_SEQUENCES = {
    "A1": [
        "a1-alphabet-pronunciation", "a1-pronouns", "a1-formal-address", "a1-sein-haben", "a1-present-tense",
        "a1-word-order", "a1-questions", "a1-articles-nominative", "a1-plurals",
        "a1-adjectives-predicative", "a1-comparative-basics", "a1-accusative",
        "a1-accusative-pronouns", "a1-dative-pronouns", "a1-negation", "a1-possessives",
        "a1-modals", "a1-imperative", "a1-separable-verbs", "a1-coordination",
        "a1-preposition-contractions", "a1-time-expressions", "a1-prepositions",
        "a1-place-direction", "a1-perfect-basic", "a1-past-sein-haben",
    ],
    "A2": [
        "a2-perfect", "a2-participle-formation", "a2-preterite", "a2-werden-changes",
        "a2-modal-past", "a2-dative", "a2-object-pronouns", "a2-double-object-order",
        "a2-two-way-prepositions", "a2-n-declension-basic", "a2-verbs-prepositions",
        "a2-pronominal-adverbs", "a2-reflexive", "a2-reflexive-dative",
        "a2-indefinite-pronouns", "a2-adjective-endings", "a2-comparative",
        "a2-time-manner-place", "a2-infinitive-zu", "a2-purpose", "a2-subordinate",
        "a2-causal-connectors", "a2-temporal-clauses", "a2-indirect-questions",
        "a2-relative-basic",
    ],
    "B1": [
        "b1-past-narrative", "b1-plusquamperfekt", "b1-temporal-connectors",
        "b1-connectors", "b1-concessive-alternatives", "b1-concessive", "b1-relative",
        "b1-relative-wo-was", "b1-konjunktiv-ii", "b1-conditionals", "b1-passive",
        "b1-alternatives", "b1-passive-modal-verbs", "b1-genitive",
        "b1-adjective-endings", "b1-n-declension", "b1-participles-adjectives",
        "b1-nominalization", "b1-collocations", "b1-modal-particles",
        "b1-extended-infinitives", "b1-result-manner", "b1-indirect-speech", "b1-future",
        "b1-konjunktiv-past",
    ],
}
PIPER_FILES = {
    f"{PIPER_VOICE}.onnx": {
        "url": "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/de/de_DE/thorsten/high/de_DE-thorsten-high.onnx?download=true",
        "md5": "256505fe58fb8b9d6ed78b83f6b8a9d2",
    },
    f"{PIPER_VOICE}.onnx.json": {
        "url": "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/de/de_DE/thorsten/high/de_DE-thorsten-high.onnx.json?download=true",
        "md5": "e81686e00a9d825e2488ead660bec6fd",
    },
}


@dataclass
class Target:
    text: str
    categories: set[str] = field(default_factory=set)
    sources: list[str] = field(default_factory=list)


def normalized(text: str) -> str:
    return " ".join(text.replace("\n", " ").split())


def fnv1a_64(text: str) -> int:
    value = 0xCBF29CE484222325
    for byte in normalized(text).encode("utf-8"):
        value ^= byte
        value = (value * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def resource_name(text: str) -> str:
    return f"neural_{fnv1a_64(text):016x}"


def load_json(name: str):
    with (RESOURCES / f"{name}.json").open(encoding="utf-8") as handle:
        return json.load(handle)


def collect_targets() -> OrderedDict[str, Target]:
    targets: OrderedDict[str, Target] = OrderedDict()

    def add(text: str, category: str, source: str) -> None:
        text = normalized(text)
        if not text:
            return
        target = targets.setdefault(text, Target(text=text))
        target.categories.add(category)
        if source not in target.sources:
            target.sources.append(source)

    add(PREVIEW_TEXT, "preview", "settings-preview")
    add(
        "Ich wohne seit zwei Jahren in Deutschland und lerne Deutsch, weil ich die B1-Prüfung bestehen möchte.",
        "speaking",
        "default-speaking-practice",
    )
    for index, text in enumerate(STANDALONE_SPEAKING_TEXTS, start=1):
        add(text, "speaking", f"standalone-speaking-{index}")

    vocabulary = []
    for pack in ("vocab_a1", "vocab_a2", "vocab_b1"):
        for word in load_json(pack):
            vocabulary.append(word)
            add(word["ttsText"], "vocabulary", f"{word['id']}:word")
            add(word["exampleSentence"], "vocabulary", f"{word['id']}:example")

    grammar = load_json("grammar")
    for topic in grammar:
        for index, example in enumerate(topic["examples"], start=1):
            add(example["german"], "grammar", f"{topic['id']}:example-{index}")
        for index, exercise in enumerate(topic["practice"], start=1):
            add(exercise["answer"], "exercise", f"{topic['id']}:exercise-{index}")

    explicit_lessons = load_json("lessons")
    explicit_grammar_ids = {lesson["grammarTopicId"] for lesson in explicit_lessons}
    for lesson in explicit_lessons:
        add(lesson["listening"]["script"], "listening", f"{lesson['id']}:listening")
        add(lesson["speaking"]["expectedAnswer"], "speaking", f"{lesson['id']}:speaking")

    grammar_by_id = {topic["id"]: topic for topic in grammar}
    for level, topic_ids in GRAMMAR_SEQUENCES.items():
        for index, topic_id in enumerate(topic_ids):
            topic = grammar_by_id[topic_id]
            if topic_id in explicit_grammar_ids:
                continue
            examples = [example["german"] for example in topic["examples"][:2]]
            first = examples[0] if examples else "Ich lerne heute Deutsch."
            second = examples[1] if len(examples) > 1 else first
            frames = [
                f"Hören Sie zuerst den Modellsatz: „{first}“ Jetzt vergleichen Sie: „{second}“ Was bleibt gleich, und was verändert sich?",
                f"Konzentrieren Sie sich zuerst auf die Bedeutung: „{first}“ Hören Sie danach das gleiche Sprachmuster in: „{second}“",
                f"Achten Sie genau auf die Satzstruktur: „{first}“ Hören Sie nun ein zweites Beispiel: „{second}“ Sprechen Sie beide Sätze leise mit.",
                f"Hören Sie in drei Schritten. Zuerst: „{first}“ Dann: „{second}“ Zum Schluss wiederholen Sie den Satz, der für Sie schwieriger war.",
                f"Ein Satzmuster, zwei klare Beispiele. Beispiel eins: „{first}“ Beispiel zwei: „{second}“ Welche Position ist in beiden Sätzen besonders wichtig?",
            ]
            script = frames[index % len(frames)]
            add(script, "listening", f"{topic_id}:generated-listening")
            if topic["examples"]:
                add(topic["examples"][0]["german"], "speaking", f"{topic_id}:generated-speaking")

    for mission in load_json("practical_missions"):
        for index, phrase in enumerate(mission["phrases"], start=1):
            add(phrase["german"], "speaking", f"{mission['id']}:phrase-{index}")
        for index, turn in enumerate(mission["turns"], start=1):
            add(turn["partnerCue"], "listening", f"{mission['id']}:cue-{index}")
            add(turn["modelResponse"], "speaking", f"{mission['id']}:response-{index}")

    for category in load_json("everyday_phrases"):
        for phrase in category["phrases"]:
            add(
                phrase["german"],
                "speaking",
                f"everyday-phrases:{category['id']}:{phrase['id']}",
            )

    exam = load_json("mock_exam_b1")
    for section in exam["sections"]:
        for index, task in enumerate(section["tasks"], start=1):
            if task.get("audioScript"):
                add(task["audioScript"], "exam", f"mock-exam:{section['skill']}-{index}")

    return targets


def selected_categories(scope: str) -> set[str]:
    if scope == "preview":
        return {"preview"}
    if scope == "core":
        return {"preview", "grammar", "listening", "speaking", "exam"}
    if scope == "vocabulary":
        return {"preview", "vocabulary"}
    return {"preview", "vocabulary", "grammar", "exercise", "listening", "speaking", "exam"}


def write_manifest(targets: OrderedDict[str, Target], output: Path, engine: str) -> None:
    clips = []
    for target in targets.values():
        filename = f"{resource_name(target.text)}.m4a"
        if (output / filename).is_file():
            clips.append(
                {
                    "id": resource_name(target.text),
                    "file": filename,
                    "text": target.text,
                    "categories": sorted(target.categories),
                    "sources": target.sources,
                }
            )
    manifest = {
        "formatVersion": 1,
        "engine": engine,
        "language": "de",
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "clipCount": len(clips),
        "clips": clips,
    }
    (output / "neural_audio_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def prune_orphan_audio(targets: OrderedDict[str, Target], output: Path) -> int:
    expected = {f"{resource_name(target.text)}.m4a" for target in targets.values()}
    removed = 0
    for path in output.glob("neural_*.m4a"):
        if path.name not in expected:
            path.unlink()
            removed += 1
    return removed


def convert_to_m4a(wav_path: Path, destination: Path) -> None:
    with tempfile.NamedTemporaryFile(suffix=".m4a", dir=destination.parent, delete=False) as handle:
        temporary = Path(handle.name)
    temporary.unlink(missing_ok=True)
    try:
        subprocess.run(
            [
                "afconvert",
                str(wav_path),
                str(temporary),
                "-f",
                "m4af",
                "-d",
                "aac",
                "-b",
                "64000",
                "-q",
                "96",
            ],
            check=True,
            capture_output=True,
            text=True,
        )
        temporary.replace(destination)
    except Exception:
        temporary.unlink(missing_ok=True)
        raise


def md5(path: Path) -> str:
    digest = hashlib.md5()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def ensure_piper_voice(model_dir: Path) -> tuple[Path, Path]:
    model_dir = model_dir.expanduser()
    model_dir.mkdir(parents=True, exist_ok=True)
    for filename, metadata in PIPER_FILES.items():
        destination = model_dir / filename
        if destination.is_file() and md5(destination) == metadata["md5"]:
            continue
        destination.unlink(missing_ok=True)
        temporary = destination.with_suffix(destination.suffix + ".download")
        temporary.unlink(missing_ok=True)
        print(f"Downloading {filename}...", flush=True)
        try:
            subprocess.run(
                ["curl", "-fL", "--retry", "3", metadata["url"], "-o", str(temporary)],
                check=True,
            )
            if md5(temporary) != metadata["md5"]:
                raise RuntimeError(f"Checksum failed for {filename}")
            temporary.replace(destination)
        finally:
            temporary.unlink(missing_ok=True)
    return model_dir / f"{PIPER_VOICE}.onnx", model_dir / f"{PIPER_VOICE}.onnx.json"


def piper_renderer(model_dir: Path, worker_threads: int):
    import onnxruntime
    from piper import PiperConfig, PiperVoice, SynthesisConfig

    model_path, config_path = ensure_piper_voice(model_dir)
    with config_path.open(encoding="utf-8") as handle:
        voice_config = PiperConfig.from_dict(json.load(handle))
    session_options = onnxruntime.SessionOptions()
    session_options.intra_op_num_threads = max(worker_threads, 1)
    session_options.inter_op_num_threads = 1
    session_options.execution_mode = onnxruntime.ExecutionMode.ORT_SEQUENTIAL
    voice = PiperVoice(
        config=voice_config,
        session=onnxruntime.InferenceSession(
            str(model_path),
            sess_options=session_options,
            providers=["CPUExecutionProvider"],
        ),
    )
    synthesis = SynthesisConfig(length_scale=1.0, noise_scale=0.667, noise_w_scale=0.8)

    def render(text: str, destination: Path) -> None:
        wrote_audio = False
        with wave.open(str(destination), "wb") as wav_file:
            for index, chunk in enumerate(voice.synthesize(text, synthesis)):
                if not wrote_audio:
                    wav_file.setframerate(chunk.sample_rate)
                    wav_file.setsampwidth(chunk.sample_width)
                    wav_file.setnchannels(chunk.sample_channels)
                    wrote_audio = True
                if index > 0:
                    wav_file.writeframes(bytes(int(chunk.sample_rate * 0.12 * chunk.sample_width)))
                wav_file.writeframes(chunk.audio_int16_bytes)
        if not wrote_audio:
            destination.unlink(missing_ok=True)
            raise RuntimeError(f"Piper generated no audio for: {text}")

    return render


def chatterbox_renderer(device: str):
    os.environ.setdefault("HF_HUB_DISABLE_XET", "1")
    os.environ.setdefault("PYTORCH_ENABLE_MPS_FALLBACK", "1")
    import torch
    import torchaudio
    from chatterbox.mtl_tts import ChatterboxMultilingualTTS

    if device == "auto":
        device = "mps" if torch.backends.mps.is_available() else "cpu"
    print(f"Loading Chatterbox Multilingual V3 on {device}...", flush=True)
    model = ChatterboxMultilingualTTS.from_pretrained(device=device, t3_model="v3")

    def render(text: str, destination: Path) -> None:
        torch.manual_seed(fnv1a_64(text) & 0x7FFFFFFF)
        waveform = model.generate(
            text,
            language_id="de",
            exaggeration=0.42,
            cfg_weight=0.35,
            temperature=0.75,
            repetition_penalty=1.25,
        )
        torchaudio.save(str(destination), waveform.cpu(), model.sr)

    return render


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scope", choices=("preview", "core", "vocabulary", "all"), default="all")
    parser.add_argument("--engine", choices=("piper", "chatterbox"), default="piper")
    parser.add_argument("--device", choices=("auto", "mps", "cpu"), default="auto")
    parser.add_argument(
        "--model-dir",
        type=Path,
        default=Path.home() / ".cache" / "deutsch-b1-coach" / "piper-voices",
    )
    parser.add_argument("--limit", type=int, help="Render at most this many missing clips")
    parser.add_argument("--overwrite", action="store_true")
    parser.add_argument("--shard-count", type=int, default=1)
    parser.add_argument("--shard-index", type=int, default=0)
    parser.add_argument("--worker-threads", type=int, default=4)
    parser.add_argument("--skip-manifest", action="store_true")
    parser.add_argument("--prune", action="store_true")
    parser.add_argument("--output", type=Path, default=OUTPUT)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    targets = collect_targets()
    categories = selected_categories(args.scope)
    requested = [target for target in targets.values() if target.categories & categories]
    if args.shard_count < 1 or not 0 <= args.shard_index < args.shard_count:
        raise ValueError("shard-index must be between 0 and shard-count - 1")
    requested = [
        target
        for target in requested
        if fnv1a_64(target.text) % args.shard_count == args.shard_index
    ]
    if not args.overwrite:
        requested = [target for target in requested if not (args.output / f"{resource_name(target.text)}.m4a").is_file()]
    if args.limit is not None:
        requested = requested[: max(args.limit, 0)]

    if not requested:
        engine = "Piper VITS de_DE-thorsten-high" if args.engine == "piper" else "Resemble AI Chatterbox Multilingual V3"
        if args.prune:
            print(f"Pruned {prune_orphan_audio(targets, args.output)} orphan clips.")
        if not args.skip_manifest:
            write_manifest(targets, args.output, engine)
        print("All requested neural clips already exist.")
        return

    if args.engine == "piper":
        engine = "Piper VITS de_DE-thorsten-high"
        render = piper_renderer(args.model_dir, args.worker_threads)
    else:
        engine = "Resemble AI Chatterbox Multilingual V3"
        render = chatterbox_renderer(args.device)
    print(f"Rendering {len(requested)} clips with {engine}...", flush=True)

    try:
        for index, target in enumerate(requested, start=1):
            name = resource_name(target.text)
            destination = args.output / f"{name}.m4a"
            print(f"[{index}/{len(requested)}] {target.text[:88]}", flush=True)
            with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as handle:
                wav_path = Path(handle.name)
            try:
                render(target.text, wav_path)
                convert_to_m4a(wav_path, destination)
            finally:
                wav_path.unlink(missing_ok=True)
            if index % 25 == 0 and not args.skip_manifest:
                write_manifest(targets, args.output, engine)
    finally:
        if args.prune:
            print(f"Pruned {prune_orphan_audio(targets, args.output)} orphan clips.")
        if not args.skip_manifest:
            write_manifest(targets, args.output, engine)

    print(f"Finished {len(requested)} clips in {args.output}")


if __name__ == "__main__":
    main()
