# Release readiness

Status: development candidate, not an App Store release certification.

## Verified locally

- `swift test`: 7 host-runnable tests for review scheduling, free-response scoring, and safe remote configuration.
- XcodeGen regenerates the shared app/test project without a personal signing team.
- Remote curriculum, access checks, and opt-in metrics require an explicit HTTPS deployment; a clean checkout uses the bundled offline curriculum.

On 2026-10-17 the [hosted workflow](https://github.com/fayselomerahmed/deutsch-b1-coach-ios/actions/runs/39033663883) passed the full simulator Release build, all 78 iOS XCTest cases with zero failures, and seven host-runnable core tests at `b263b2ab`. The local machine's missing iOS runtime remains a local tooling limitation, not a substitute for this hosted build evidence.

## Required before release

- [x] Green hosted simulator Release build and full XCTest, including curriculum and speech checks.
- [ ] Test migrations, progress reset, offline launch, denied permissions, Dynamic Type, VoiceOver, and memory pressure on physical devices.
- [ ] Teacher review of generated lessons, translations, feedback, and practice exams; never market practice material as an official certificate.
- [ ] Confirm model/runtime licensing and notices, app size, device performance, and native runtime stability.
- [ ] Configure the intended studio deployment, trusted authentication gateway, D1 migrations, and owner activation secret; test publishing, rollback, and access expiry end to end.
- [ ] Configure and sandbox-test StoreKit products, refunds, revocation, expiry, restoration, and subscription disclosures.
- [ ] Supply distribution signing, App Store privacy declarations, operator-specific privacy/support URLs and private contact, screenshots, and review metadata.

Keep API secrets out of the app. SHA-256 detects payload corruption but is not a publisher signature; transport and authenticated publishing are part of the trust boundary.
