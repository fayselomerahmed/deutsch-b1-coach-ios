# Deutsch B1 Coach

The course can teach through 20 languages: English, Amharic, Arabic, Simplified Chinese, Dutch, French, Hindi, Indonesian, Italian, Japanese, Korean, Polish, Portuguese, Russian, Spanish, Thai, Tigrinya, Turkish, Ukrainian, and Vietnamese. Bundled explanations cover the complete learning interface; on supported systems Apple translation can assist new live content while German examples remain unchanged and English remains available as a fallback.

Deutsch B1 Coach is a native, offline-first SwiftUI learning app for adult German learners from A1 through B1. It combines a structured lesson path, active-recall flashcards, spaced repetition, speaking and writing practice, skill analytics, and a B1-style practice exam.

## Product Scope

- 75 guided lessons: 25 at each CEFR level, each with eight learning stages.
- 702 vocabulary entries: 252 A1, 221 A2, and 229 B1 flashcards, each with a unique contextual example and an offline word-specific visual mnemonic.
- 75 grammar units and 908 distinct exercises: at least 9 per topic across translation, cloze, correction, and sentence order.
- 2,799 vocabulary, article, two-direction recall, and grammar quiz prompts.
- 15 real-life speaking missions across introductions, services, health, travel, housing, work, authorities, negotiation, and B1 exam interaction.
- SM-2 review scheduling for activated vocabulary and grammar.
- Reading, listening, writing, and speaking practice with local scoring, corrected German, concrete error feedback, and retry suggestions.
- Twelve-question placement assessment and persistent level recommendation.
- B1-style timed practice exam across all four skills.
- SwiftData progress history, streaks, XP, mastery, milestones, and seven-day activity charts.
- StoreKit 2 monthly and annual offers, restoration of legacy lifetime purchases, and institutional access through a privacy-preserving iPhone Access ID.
- 2,580 instant offline German clips plus on-device neural generation for personalized corrections, all using the same Thorsten voice.
- Local study reminders, Dynamic Type, VoiceOver labels, dark mode, and an Apple privacy manifest.

All curriculum and learner progress work offline. Speech recognition uses Apple's on-device/system Speech framework when available; no custom analytics or advertising SDK is included.

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

The live owner dashboard at `https://example.invalid` uses Cloudflare D1, a managed SQLite-compatible database, to store versioned curriculum and hashed managed-access records. Learner progress and speech data remain on the iPhone. See `DeutschB1Coach/Docs/LiveContentSetup.md` for the activation workflow.

## Documentation

- `DeutschB1Coach/Docs/Architecture.md`
- `DeutschB1Coach/Docs/CurriculumPlan.md`
- `DeutschB1Coach/Docs/DesignSystem.md`
- `DeutschB1Coach/Docs/ProductStrategy.md`
- `DeutschB1Coach/Docs/AppStoreLaunch.md`
- `DeutschB1Coach/Docs/TeacherReviewProtocol.md`
