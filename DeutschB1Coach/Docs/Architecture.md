# Architecture

Deutsch B1 Coach is an iOS 17+ SwiftUI application with local-first content and learner state.

## Layers

- `App`: app lifecycle and SwiftData container configuration.
- `Models`: curriculum DTOs, SwiftData entities, review state, exam models, and activity records.
- `Services`: JSON loading, curriculum generation, SM-2 scheduling, progress aggregation, speech scoring, reminders, and StoreKit 2 entitlements.
- `ViewModels`: lesson, quiz, dashboard, review, and speaking state machines.
- `Views`: five-tab product UI, onboarding, learning flows, practice labs, settings, and premium purchase surfaces.
- `Resources`: versioned JSON curriculum and practical missions, generated neural audio, the offline Thorsten voice model, asset catalog, app icon, and Apple privacy manifest.

## Content Pipeline

1. Versioned JSON files ship in the application bundle.
2. `ContentLoader` validates and decodes them on first launch.
3. `CurriculumFactory` combines the 76 bundled grammar topics and 702 vocabulary entries into 76 complete lessons and 2,811 quiz prompts; `ContentLoader` also decodes 25 real-life conversation missions.
4. SwiftData stores curriculum entities and separate learner-owned state.
5. `ProgressService` records XP, attempts, review outcomes, mastery, streaks, and skill activity.

Seeding is idempotent. Existing learner progress remains intact when the application launches again.

These counts describe the bundled curriculum. The quiz total follows the current factory: five explicit prompts, two prompts per vocabulary entry (1,404), 482 article prompts, and 920 grammar-practice prompts. Published curriculum updates can change the available content.

## Persistence

- `GrammarTopic`, `VocabWord`, and `QuizQuestion` hold curriculum content.
- `ReviewItem` stores activation and SM-2 scheduling state.
- `LessonRecord` stores resumable lesson progress.
- `LearningActivity` records dated skill activity and XP.
- `UserProgress` stores level and skill mastery trends.
- `AppStorage` holds lightweight preferences such as selected tab, learner name, goals, and reminder time.

## Platform Services

- Piper's German VITS model generates AAC clips locally during development. `GermanSpeechService` plays those assets first, then uses `OnDeviceGermanVoiceRenderer` and sherpa-onnx to generate uncovered or personalized text with the same Thorsten voice. Generation runs off the main thread and caches successful WAV files locally. Chatterbox Multilingual V3 remains an optional development-time renderer for higher-memory hardware.
- UserNotifications schedules the optional local study reminder.
- StoreKit 2 loads products, purchases, restores, and observes entitlement changes. `PremiumAccessService` also checks privacy-preserving managed trial/full entitlements from the content service using a Keychain-backed random Access ID; an App Store purchase or an active managed entitlement grants premium access.
- Swift Charts renders activity and readiness analytics.

Cloudflare D1 stores published curriculum versions, owner configuration, and hashed managed-access records. Learner progress, speech, identity, and study activity remain local. No advertising SDK or third-party learner tracking is included, and cloud progress sync remains outside the current offline-first release.

## Quality Gates

- `Tools/generate_curriculum.js` can regenerate and validate curriculum packs.
- `Tools/generate_neural_audio.py` generates offline German audio packs without an API key, using stable text-derived asset names to resume work and reuse completed clips.
- `CurriculumIntegrityTests` checks per-level counts, references, answerable questions, and generation of natural audio for a non-pre-recorded correction.
- Scheduler and speech scoring have focused unit tests.
- The [hosted build workflow](../../.github/workflows/build.yml) performs a Release simulator build, runs the full iOS XCTest suite, and runs the host-compatible core tests with `swift test`.
