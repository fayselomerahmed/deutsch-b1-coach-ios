# Privacy in the development build

Learning progress, answers, vocabulary reviews, and local audio caches stay on the device. Speech practice requests microphone and Apple Speech permissions; recognition availability and processing depend on Apple's platform settings. The app does not send recordings or transcripts to Curriculum Studio.

The public configuration leaves remote curriculum and analytics endpoints unset. Optional improvement sharing is off by default. If a deployment is configured and sharing enabled, only aggregate event names and app-build counts are submitted. Managed-access checks use a random Access ID; the service stores its hash rather than a learner name. App Store purchases are processed by Apple.

Progress can be reset in Settings. Manage microphone, speech, and notification permissions in iOS Settings and subscriptions in your Apple Account.

Do not post personal information, recordings, payment details, or Access IDs in public project issues. Before distributing a production build, its operator must provide an accurate deployment-specific policy and a private privacy-request contact. This document describes the public development configuration, not a legal compliance certification.
