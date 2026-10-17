# Release readiness

Status: development candidate, not an App Store release certification.

## Implemented safeguards

- `swift test`: 13 host-runnable tests for review scheduling, free-response scoring, safe remote configuration, and bounded managed-access refresh policy.
- XcodeGen regenerates the shared app/test project without a personal signing team.
- Remote curriculum, access checks, and opt-in metrics require an explicit HTTPS deployment; a clean checkout uses the bundled offline curriculum.
- Persistent-container failures show a retry screen without deleting data, moving the store, or silently falling back to in-memory progress.
- Managed-access refreshes use a foreground cadence and bounded failure backoff; verified cache timestamps must be finite and not in the future.

On 2026-10-17 the [hosted workflow](https://github.com/fayselomerahmed/deutsch-b1-coach-ios/actions/runs/39064142087) passed the full simulator Release build, all 87 iOS XCTest cases with zero failures, and 13 host-runnable core tests at `61a68bc`. The core package reuses a subset of the iOS test files. The local machine's missing iOS runtime remains a local tooling limitation, not a substitute for this hosted build evidence.

A separate [screenshot workflow](https://github.com/fayselomerahmed/deutsch-b1-coach-ios/actions/runs/39063739835) built and launched the app and captured the bundled-curriculum interface on an iPhone simulator. These genuine captures confirm the shown screens rendered, not physical-device performance or service integration.

## Required before release

- [x] Green hosted simulator Release build and full XCTest, including curriculum and speech checks.
- [ ] Test migrations, progress reset, offline launch, denied permissions, Dynamic Type, VoiceOver, and memory pressure on physical devices.
- [ ] Teacher review of generated lessons, translations, feedback, and practice exams; never market practice material as an official certificate.
- [ ] Confirm model/runtime licensing and notices, app size, device performance, and native runtime stability.
- [ ] Configure the intended studio deployment, trusted authentication gateway, D1 migrations, and owner activation secret; test publishing, rollback, and access expiry end to end.
- [ ] Configure and sandbox-test StoreKit products, refunds, revocation, expiry, restoration, and subscription disclosures.
- [ ] Supply distribution signing, App Store privacy declarations, operator-specific privacy/support URLs and private contact, screenshots, and review metadata.

Keep API secrets out of the app. SHA-256 detects payload corruption but is not a publisher signature; transport and authenticated publishing are part of the trust boundary.
