# Live Content

The shipped app receives curriculum updates from the hosted Deutsch Coach Content Studio. Learners have read-only access. Publishing, rollback, and removal require the activated owner account.

Owner dashboard: `https://example.invalid`

## Publishing after release

1. Open the dashboard directly, or open Settings in the app and tap the Version row seven times.
2. Sign in with ChatGPT. On first use, enter the one-time owner activation code.
3. Choose a curriculum section such as lessons, grammar, vocabulary, quizzes, missions, or phrases.
4. Search the current app content, then add, edit, duplicate, or remove items with the guided form.
5. Select **Publish to app**. Draft changes remain private until this step.
6. The dashboard and iPhone both validate content integrity. Learners receive verified changes when the app opens or returns to the foreground.

The published file is versioned and protected by a SHA-256 digest. Devices retain the last verified copy for offline use. Removing a live file returns learners to the curriculum bundled with their installed app version.

The **Version and file tools** area includes JSON import/export for backups, minimum-build targeting, rollback, draft reset, and restoration of the app's included curriculum. Normal lesson management does not require editing JSON.

## Trial and full access

1. The learner opens **Premium** in the app and copies the private Access ID shown there.
2. Open **User access** in the owner dashboard.
3. Add a short internal reference, paste the Access ID, and choose a 7, 14, 30, or 90-day trial or the full version.
4. The learner taps **Check access**, reopens the app, or returns it to the foreground. Trials expire automatically; full access remains active until it is paused or removed.

App Store purchases remain valid independently of managed access. The Access ID is generated on the iPhone, stored in its Keychain, and hashed with SHA-256 before it is saved by the backend. The access check sends no learner name, email, study history, or voice recording. A last verified active entitlement has a 72-hour offline grace period.

## Backend database

The hosted service uses **Cloudflare D1**, Cloudflare's managed SQLite-compatible database, through the `DB` binding configured in `.openai/hosting.json`. It stores these tables:

- `app_settings`: the activated owner account.
- `content_files`: the currently published curriculum files.
- `content_versions`: version history used for rollback.
- `access_entitlements`: hashed iPhone Access IDs, an owner-entered reference, trial/full status, expiry, and enabled state.

Learner progress remains in SwiftData on the iPhone and is not uploaded to D1.

## Supported files

- `grammar.json`
- `vocab_a1.json`
- `vocab_a2.json`
- `vocab_b1.json`
- `lessons.json`
- `quizzes.json`
- `practical_missions.json`
- `everyday_phrases.json`
