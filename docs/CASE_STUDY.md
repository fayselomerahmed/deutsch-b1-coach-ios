# Engineering case study: Deutsch B1 Coach

## Goal and scope

Build a native learning app in which a learner can study vocabulary, complete lessons, practise speaking, and retain progress without depending on an always-available backend. The project combines a SwiftUI interface with persistent learning records, testable learning logic, and a native on-device speech integration.

The [README](../README.md) summarizes features and setup. This case study connects the design decisions to their implementation and test evidence.

## 1. Separate course content from learner state

Curriculum changes and learner progress have different lifecycles. [ContentLoader](../DeutschB1Coach/Services/ContentLoader.swift) reads bundled data, matches existing records by stable IDs, updates curriculum fields, and creates missing review records. Progress is represented in dedicated SwiftData models rather than embedded in downloaded content files.

[CurriculumFactory](../DeutschB1Coach/Services/CurriculumFactory.swift) expands the source material into practice. This supports a larger course from reusable data, but generated material still needs pedagogical review. Structural validation and passing tests cannot establish that every explanation, translation, or exam question is educationally correct.

Optional remote content follows a versioned file contract with minimum-build targeting and SHA-256 checks. The client retains verified content for offline use. Hash checks detect corruption; they do not replace HTTPS, authenticated publishing, or deployment security.

Repeated screen loads reuse successfully decoded sources and derived lesson/quiz arrays through a [revision-scoped cache](../DeutschB1Coach/Services/ContentRevisionCache.swift). The existing owner-content revision invalidates all cached values after imports, restoration, rollback, or live updates. Failures are not cached, so retry can recover. Main-actor isolation and synchronous loaders prevent concurrent duplicate work. This retains immutable course values in memory; it does not remove the first-load cost or establish a physical-device latency benchmark.

Integration tests confirm that repeated lesson/quiz loads read their six source files only once per revision while preserving all 76 lessons and 2,811 quiz prompts. A separate revision-change check verifies refreshed content appears without restarting the loader.

If the persistent container cannot open, [startup state](../DeutschB1Coach/App/ModelContainerStartup.swift) shows a retry path against the same store. It does not delete the store or fall back to volatile data while implying progress is saved. Optional managed-access refreshes also remain outside this startup dependency: they run only with configured services and use bounded retry backoff.

## 2. Put review and scoring logic outside views

The [SM-2 scheduler](../DeutschB1Coach/Services/SM2Scheduler.swift) returns the next interval, ease factor, repetition count, lapse count, and due date. Its inputs include the review date and calendar, which makes scheduling behavior directly testable.

[FreeResponseEvaluator](../DeutschB1Coach/Services/FreeResponseEvaluator.swift) normalizes text and scores essential-word overlap. [SpeechScorer](../DeutschB1Coach/Services/SpeechScorer.swift) handles speaking feedback separately from microphone/recognition lifecycle code. These are coaching heuristics, not certified language assessment or a claim of human-level grading.

A small Swift package reuses the app's pure scheduling, free-response, and configuration source files for fast host-runnable tests. The broader Xcode suite exercises curriculum and speech behavior in the iOS app target.

## 3. Choose offline audio deliberately

[OnDeviceGermanVoiceRenderer](../DeutschB1Coach/Services/OnDeviceGermanVoiceRenderer.swift) wraps the native neural speech bridge. It serializes inference on a background queue, writes to a temporary file, validates output, moves successful audio into the cache, and prunes older files. Common speech is already bundled, avoiding regeneration for familiar material.

The benefit is local speech generation without a paid TTS API or a network round trip. The cost is a larger download, native-framework integration, and additional device-performance and licensing checks. The recognizer is a separate concern: Apple Speech support and processing depend on the device and platform permissions.

## Evidence and remaining work

The [hosted CI run](https://github.com/fayselomerahmed/deutsch-b1-coach-ios/actions/runs/39072623138) at `1e0f92e` passed a Release simulator build, 94 iOS XCTest cases, and 18 host-runnable core tests. The core package intentionally reuses part of the iOS suite. This provides reproducible compilation and regression evidence—not physical-device performance measurements, a service integration test, or a teaching-quality certification.

Before distribution, follow the [release gates](../PRODUCTION_READINESS.md), particularly physical-device speech tests, curriculum review, purchases/restoration, privacy declarations, and native-runtime notices.

## Content and audio maintenance

The curriculum generator is deterministic and idempotent:

```bash
node Tools/generate_curriculum.js
```

Bundled neural clips can be regenerated with the provided tool:

```bash
python3.11 -m venv .venv-neural-audio
source .venv-neural-audio/bin/activate
pip install -r Tools/requirements-neural-audio.txt
python Tools/generate_neural_audio.py --scope preview
xcodegen generate
```

The audio tool is resumable and skips completed clips. Use `--scope all` for a full generation run. Keep [third-party notices](../DeutschB1Coach/Docs/ThirdPartyNotices.md), runtime licenses, and model attribution with redistributed assets.
