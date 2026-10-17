# Release readiness

Status: development candidate, not an App Store release certification.

## Verified locally

- `swift test`: 7 host-runnable tests for review scheduling, free-response scoring, and safe remote configuration.
- XcodeGen regenerates the shared app/test project without a personal signing team.
- Remote curriculum, access checks, and opt-in metrics require an explicit HTTPS deployment; a clean checkout uses the bundled offline curriculum.

Full simulator Release build and XCTest were attempted on 2026-10-17 but blocked by this machine's unavailable iOS platform/simulator runtime. The checked-in workflow performs those checks on a configured hosted Mac; adding it does not itself mean a successful run.

## Required before release

- [ ] Green hosted simulator build and full XCTest, including curriculum and speech checks.
- [ ] Test migrations, progress reset, offline launch, denied permissions, Dynamic Type, VoiceOver, and memory pressure on physical devices.
- [ ] Teacher review of generated lessons, translations, feedback, and practice exams; never market practice material as an official certificate.
- [ ] Confirm model/runtime licensing and notices, app size, device performance, and native runtime stability.
- [ ] Configure the intended studio deployment, trusted authentication gateway, D1 migrations, and owner activation secret; test publishing, rollback, and access expiry end to end.
- [ ] Configure and sandbox-test StoreKit products, refunds, revocation, expiry, restoration, and subscription disclosures.
- [ ] Supply distribution signing, App Store privacy declarations, operator-specific privacy/support URLs and private contact, screenshots, and review metadata.

Keep API secrets out of the app. SHA-256 detects payload corruption but is not a publisher signature; transport and authenticated publishing are part of the trust boundary.
