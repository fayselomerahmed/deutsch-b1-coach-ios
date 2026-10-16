# Release Checklist

## Verified In The Project

- The A1-B1 curriculum, quizzes, mock exam, review queue, speaking practice, and local progress persistence are bundled and work offline.
- The app icon, microphone and speech usage descriptions, encryption declaration, Education category, and privacy manifest are included.
- Exam readiness is based on the learner's latest result in all four practice sections and does not claim official provider scoring or guaranteed exam results.
- Unit-test compilation covers curriculum integrity, neural audio assets, readiness calculation, and privacy-manifest structure.
- Free learners can prove value at their placed level through a lesson, speaking correction, and short readiness direction before upgrading.
- The purchase screen is annual-first, contains renewal disclosure and restore access, and keeps school/partner grants separate from consumer purchases.
- Live curriculum publishing rejects thin grammar units, repeated examples, incomplete lessons, and incomplete real-life missions.

## Complete Before App Store Submission

- Archive with the distribution certificate and run Xcode's Validate App workflow.
- Test microphone, speech recognition, neural audio playback, notifications, restore purchases, and accessibility on at least one physical iPhone.
- Create the monthly and annual subscription products in App Store Connect, add a seven-day introductory trial, then verify purchase, cancellation state, expiration, and restore in the sandbox.
- Keep the lifetime product unavailable for sale while preserving restoration for any earlier entitlement.
- Add final support, privacy-policy, and terms URLs in App Store Connect.
- Complete App Privacy answers from the final binary's Xcode privacy report.
- Capture final App Store screenshots from the release build and submit the chosen exam-provider disclaimer in review notes.
- Complete the teacher and learner sign-off in `TeacherReviewProtocol.md` before paid acquisition.
- Create the audience-specific product pages and offer-code campaigns listed in `AppStoreLaunch.md`.
