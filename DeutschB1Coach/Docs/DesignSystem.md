# Design System

Deutsch B1 Coach is a warm, focused learning tool designed for repeated daily use. It uses native iOS patterns, compact information density, clear feedback, and expressive color with stable semantic meaning.

## Foundations

- The page gradient moves from warm coral and gold through focused mint to reflective blue-violet, giving each study session a calm visual rhythm in light and dark mode.
- Teal denotes focus and primary learning actions, coral denotes momentum and memory cues, accessible amber denotes understanding and reward, blue denotes listening, and purple denotes speaking.
- Bright gold is decorative only; readable labels and controls use a deeper amber with sufficient contrast.
- SF Pro text styles preserve Dynamic Type; fixed viewport-scaled typography is avoided.
- Cards use an 8-point radius and subtle borders. Full page sections remain unframed.
- Icons come from SF Symbols and icon-only controls include accessibility labels.

## Components

- `CoachCard`: individual lesson, metric, and task container.
- `PrimaryCoachButton`: prominent command action.
- `SkillChip`: compact CEFR or skill metadata.
- `MetricRing`: stable progress and readiness visualization.
- Segmented level pickers, menus for filters, toggles for settings, and standard navigation links.

## Interaction

- Correct and incorrect states use color, symbols, and explanatory text together.
- Flashcards begin recall-first and reveal grading controls only after the answer.
- Lesson records make every guided path resumable.
- Empty, loading, permission, and error states provide a meaningful next action.
- Touch targets are at least 44 points and layouts use adaptive stacks and system spacing.

## Accessibility

Dynamic Type, dark mode, VoiceOver labels and actions, reduced reliance on color, and landscape support are part of the release baseline. German speech playback remains separate from card-flip actions so assistive technologies expose both controls reliably.
