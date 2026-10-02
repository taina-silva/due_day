# Tasks — 0000

## 1. Specs
- [x] 1.1 Create `specs/README.md` (workflow, formats, requirement IDs, doc-update rules)
- [x] 1.2 Create `specs/product.md` (vision, focus, scope, decisions D1–D11, glossary)
- [x] 1.3 Create `specs/capabilities/` and `specs/changes/archive/`
- [x] 1.4 Draft proposals for `0001`–`0004`

## 2. Docs consolidation (`.claude/references/` → `.claude/docs/`)
- [x] 2.1 Merge `dependency_map`, `feature_development`, `project_structure` (summary) and technical glossary into `architecture.md`
- [x] 2.2 Merge `firestore_schema.md` into `firestore.md`; correct schema to match current models
- [x] 2.3 Remove duplicated "Generating Pages & Widgets" section from `coding_standards.md` (renumber §9 → §8)
- [x] 2.4 Move `dependency_injection.md`, `localization.md` to `docs/`; `firebase_setup.md`, `security_hardening.md` to `docs/setup/`
- [x] 2.5 Move domain glossary to `specs/product.md`; delete `glossary.md`
- [x] 2.6 Fix all relative links in docs, skills, and agents

## 3. Stale facts
- [x] 3.1 Remove FCM/push mentions (CLAUDE.md, architecture, firebase_setup, security_hardening, firebase-engineer, add-notification)

## 4. Skills & agents
- [x] 4.1 Add `spec-propose` skill
- [x] 4.2 Add `spec-apply` skill
- [x] 4.3 `code-reviewer`: spec-compliance focus area
- [x] 4.4 `flutter-architect`: spec-alignment focus area

## 5. CLAUDE.md
- [x] 5.1 New product overview + current phase
- [x] 5.2 *Specs & Docs Workflow* section
- [x] 5.3 Updated documentation map

## 6. Cleanup
- [x] 6.1 Delete `.claude/plans/` and root `docs/` (all plans already executed)
- [x] 6.2 Remove both entries from `.gitignore`

## 7. Verification
- [x] 7.1 No broken relative links across `.claude/`, `specs/`, `CLAUDE.md`
- [x] 7.2 No remaining references to removed files
