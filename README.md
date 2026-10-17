# Deutsch B1 Coach

My German-learning project for adult learners progressing from A1 to B1. I bring lessons, vocabulary review, speaking practice, writing, and exam preparation into a native iPhone experience that keeps curriculum and learner progress available offline.

**SwiftUI · SwiftData · Swift Concurrency · Speech · StoreKit 2 · Swift Charts · on-device neural audio**

## What the app does

- Guides learners through placement, a structured lesson path, and everyday conversation missions.
- Includes 702 bundled vocabulary entries across A1, A2, and B1, with contextual examples and visual mnemonics.
- Generates lessons and quiz practice from versioned curriculum data, with SM-2 scheduling for vocabulary and grammar review.
- Provides speaking and writing practice, local feedback, and a timed B1-style practice exam.
- Tracks study activity, mastery, streaks, and XP in SwiftData, with charts for progress and readiness.
- Supports explanations in 20 teaching languages, local study reminders, Dynamic Type, VoiceOver labels, and dark mode.
- Integrates StoreKit 2 subscriptions, purchase restoration, and managed-access entitlements.

The core course and progress work offline. Speech recognition availability depends on Apple's Speech framework and the device's supported languages.

## Engineering decisions

I separate bundled curriculum from learner-owned records so content can be refreshed while retaining study history. `ContentLoader` synchronizes stable content IDs; `CurriculumFactory` expands the source packs into lesson and quiz material. Review scheduling and response scoring live in dedicated services rather than in views.

For audio, bundled German clips cover common content, while sherpa-onnx renders new corrections on the device using the same Thorsten voice. Generation runs off the main thread and caches successful output. This keeps personalized speech independent of a paid speech API, at the cost of a larger application bundle and native runtime dependencies.

Optional curriculum updates come from the companion [Curriculum Studio](https://github.com/fayselomerahmed/deutsch-b1-coach-studio). The app verifies content hashes and retains a local copy; a remote service is not required for the bundled course.

## Start reading the code

- [App entry point](DeutschB1Coach/App/DeutschB1CoachApp.swift) — lifecycle and persistence setup.
- [Content loader](DeutschB1Coach/Services/ContentLoader.swift) and [curriculum factory](DeutschB1Coach/Services/CurriculumFactory.swift) — content synchronization and generated practice.
- [SM-2 scheduler](DeutschB1Coach/Services/SM2Scheduler.swift) — review intervals, ease, and lapse handling.
- [On-device voice renderer](DeutschB1Coach/Services/OnDeviceGermanVoiceRenderer.swift) — native inference integration and audio caching.
- [View models](DeutschB1Coach/ViewModels) and [views](DeutschB1Coach/Views) — lesson, review, dashboard, and speaking flows.
- [Tests](DeutschB1Coach/Tests) — curriculum integrity, scheduling, free-response evaluation, and speech scoring.

## Build

Requirements: Xcode with the iOS 17 SDK or newer, [XcodeGen](https://github.com/yonaskolb/XcodeGen), and [Git LFS](https://git-lfs.com/). Git LFS stores the on-device neural speech model and runtime binaries that exceed GitHub's normal per-file limit.

```bash
git lfs install
git lfs pull
xcodegen generate
open DeutschB1Coach.xcodeproj
```

Select the `DeutschB1Coach` scheme and an iPhone. For a physical device, choose your development team under Signing & Capabilities and keep automatic signing enabled.

The curriculum generator is deterministic and idempotent:

```bash
node Tools/generate_curriculum.js
```

Instant neural audio is generated locally on the Mac with Piper's German VITS voice and bundled as compact AAC clips. The matching Thorsten model and sherpa-onnx runtime also ship in the app, allowing new corrections and role-play replies to use the same voice entirely on-device. No API key, network request, or paid speech service is required:

```bash
python3.11 -m venv .venv-neural-audio
source .venv-neural-audio/bin/activate
pip install -r Tools/requirements-neural-audio.txt
python Tools/generate_neural_audio.py --scope all
xcodegen generate
```

The generator downloads and verifies the pinned CC0-trained `de_DE-thorsten-high` voice, is resumable, and skips finished clips. Use `--scope preview`, `--scope core`, or `--scope vocabulary` for smaller runs. Chatterbox Multilingual V3 remains available as a much slower high-resource option after installing `chatterbox-tts==0.1.7`; select it with `--engine chatterbox --overwrite`.

## Release Configuration

Create these subscription products in App Store Connect before testing production purchases:

- `deutschb1coach.premium.monthly`
- `deutschb1coach.premium.yearly`

Keep `deutschb1coach.premium.lifetime` unavailable for sale. The app recognizes it only so any earlier purchase remains restorable.

App Store distribution also requires product pricing/localization, screenshots, support and privacy-policy URLs, subscription review metadata, and a distribution provisioning profile. The bundled B1 exam is practice material and is not affiliated with Goethe-Institut, telc, or another examination provider.

The optional companion studio uses Cloudflare D1 to store versioned curriculum and hashed managed-access records. Configure your deployment's endpoint through `LiveContentBaseURL`; see [Live Content Setup](DeutschB1Coach/Docs/LiveContentSetup.md) for the activation workflow. Learner progress and speech data remain on the iPhone.

## Validation and current status

Seven host-runnable core tests pass with `swift test`, covering scheduling, free-response scoring, and HTTPS-only remote configuration. The Xcode suite additionally covers curriculum integrity and speech scoring. Build/test automation is included for both core and iOS checks.

A full local simulator build was attempted but blocked by the installed iOS platform/runtime, so the iOS build and full XCTest are not yet verified. See [release readiness](PRODUCTION_READINESS.md) for the remaining service, device, curriculum, and App Store checks. Remote services default to disabled in the public configuration; set your own `LiveContentBaseURL` to enable them.

This is a development project. Production purchases require App Store Connect configuration, and curriculum and exam material still need the review described in the teacher-review protocol before a release claim. The B1 practice material is not an official exam or certification.

## Documentation

- [Architecture](DeutschB1Coach/Docs/Architecture.md)
- [Curriculum plan](DeutschB1Coach/Docs/CurriculumPlan.md)
- [Design system](DeutschB1Coach/Docs/DesignSystem.md)
- [Product strategy](DeutschB1Coach/Docs/ProductStrategy.md)
- [App Store launch](DeutschB1Coach/Docs/AppStoreLaunch.md)
- [Teacher-review protocol](DeutschB1Coach/Docs/TeacherReviewProtocol.md)
- [Third-party notices](DeutschB1Coach/Docs/ThirdPartyNotices.md) — Piper, the Thorsten voice, sherpa-onnx, and optional Chatterbox tooling.
