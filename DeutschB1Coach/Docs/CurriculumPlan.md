# A1-B1 Curriculum

The shipped curriculum contains 75 sequenced grammar units, 908 unique grammar exercises, 75 guided lessons, 702 vocabulary entries, and 2,799 generated checks. Every vocabulary entry includes a teaching-language meaning, unique contextual example, TTS form, theme, difficulty, article/plural where relevant, and an offline visual mnemonic built from the word's meaning and context.

## Integration-Course Structure

The 75 language lessons are organized as six chronological sections: Basiskurs 1-3 and Aufbausprachkurs 1-3. Each CEFR level contains two sections, and each section ends with a checkpoint. This is a self-study mapping to the BAMF general integration-course structure, not a claim that an app lesson equals a 45-minute Unterrichtseinheit or replaces an approved course.

Every lesson is mapped to one of the twelve BAMF everyday action fields or a cross-cutting communication field. The coverage includes public offices, work, job search, education and training, banks and insurance, childcare and school, shopping, health, media, mobility, housing, course participation, migration and identity, feelings and opinions, social contact, language learning, and conflict resolution.

Each guided lesson now names three outcomes: a practical action the learner can complete, the grammar tool used to make meaning clear, and a repair strategy for misunderstandings. Speaking and writing tasks use an authentic setting and text type, the recap ends with a real-life transfer mission, and civic/participation notes connect language use with reliable sources, rights, responsibilities, and respectful interaction.

## Orientation Course

The orientation companion follows the current 100-UE framework: introduction (3 UE), Politics in Democracy (35 UE), History and Responsibility (20 UE), People and Society (38 UE), and consolidation (4 UE). Its 16 chronological lessons include core concepts, realistic cases, perspective-taking, answerable checks, and a concrete participation task. Progress unlocks strictly in order. This companion prepares learners conceptually but does not replace required attendance or the official Leben in Deutschland test.

## A1

252 vocabulary cards and 25 grammar units cover introductions, family, home, food, shopping, time, weather, feelings, transport, health, work, communication, public offices, formal address, articles, present tense, comparisons, dative pronouns, contractions, past states, commands, place and direction, and introductory perfect tense.

The learner outcome is independent handling of familiar everyday exchanges and short personal messages.

## A2

221 vocabulary cards and 25 grammar units extend daily life into housing, services, employment, travel, health, authorities, social situations, Perfekt and Präteritum, participle formation, object order, TeKaMoLo, weak masculine nouns, dative reflexive forms, change with werden, temporal and causal clauses, comparisons, adjective endings, and infinitive constructions.

The learner outcome is participation in routine practical situations and connected descriptions of personal experience.

## B1

229 vocabulary cards and 25 grammar units focus on workplace communication, formal correspondence, education, media, environment, society, integration, exam language, opinions and argumentation, past-perfect narration, precise time relationships, unreal past conditions, modal particles, richer concessions, modal passive voice, relative clauses with wo and was, advanced infinitive and result clauses, and reported information.

The learner outcome is clear connected communication about familiar, professional, and social topics plus structured B1-style exam practice.

## Practical Fluency

Each level includes five guided real-life missions. Learners listen to a partner, produce three spoken responses, receive clarity, grammar, fluency, and vocabulary feedback, compare their transcript with corrected German, review specific errors and successful phrases, rehearse a reusable phrase bank, and complete a writing follow-up. The situations progress from introductions, cafés, shopping, directions, and appointments at A1 through housing, work, health, travel, and authorities at A2 to interviews, team problem-solving, formal requests, housing disputes, and B1 oral-exam interaction at B1.

Standalone speaking and writing tasks are level-specific. Listening free responses are evaluated against answer meaning, and overall readiness includes all four active skills even when a skill has not yet been practised.

## Lesson Pattern

Each guided lesson contains eight stages: scenario and objective, vocabulary activation, grammar explanation, examples, controlled practice, writing, speaking, and completion. Completing a lesson grants XP and activates its vocabulary and grammar for spaced repetition.

## Assessment

- Placement: 12 questions distributed across A1, A2, and B1 skills.
- Unit checks: multiple choice, typed production, article recognition, meaning recall, translation, cloze, correction, and sentence ordering.
- Review: recall-first flashcards graded Again, Hard, Good, or Easy with SM-2 scheduling.
- Skill labs: levelled reading/listening questions, writing rubrics, and speech recognition feedback.
- B1 practice exam: timed listening, reading, writing, and speaking sections with local scoring.

The practice exam is original preparation material and does not claim official alignment or endorsement by a named exam provider.

## Maintaining Content

Run `node Tools/generate_curriculum.js` after editing source packs. The generator is deterministic and safe to run repeatedly. `CurriculumIntegrityTests` protects minimum counts, uniqueness, required fields, lesson references, and question answerability.
