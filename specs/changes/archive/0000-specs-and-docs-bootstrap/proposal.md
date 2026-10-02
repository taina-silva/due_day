# 0000 — Specs and docs bootstrap

Status: done

## Why

The project had ~18k words of "how to code" documentation and no record of what the product should do. Docs overlapped (architecture in 5 files, Firestore in 3), the `docs/` vs `references/` split was unclear, several files were stale (FCM, account balances), and working plans lived in gitignored folders and got lost. Before the MVP work (`0001`–`0004`), the documentation must give future implementation sessions a single, accurate source for the product (*what/why*) and for the code (*how*).

## What

1. Create `specs/` with `README.md` (workflow and rules), `product.md` (vision, focus, scope, decisions, glossary), `capabilities/` (created on demand), and `changes/` (with the MVP changes `0001`–`0004` as proposals).
2. Consolidate `.claude/docs/` + `.claude/references/` into a single `.claude/docs/` folder:
   - `architecture.md` absorbs `dependency_map.md`, `feature_development.md`, a summary of `project_structure.md` (no directory tree), and the technical half of `glossary.md`.
   - `firestore.md` absorbs `firestore_schema.md`; the schema is corrected to match the current `freezed` models.
   - `coding_standards.md` drops the duplicated "Generating Pages & Widgets" section.
   - `dependency_injection.md` and `localization.md` move to `docs/`; `firebase_setup.md` and `security_hardening.md` move to `docs/setup/`.
   - The domain half of `glossary.md` moves to `specs/product.md`.
3. Remove FCM/push mentions from `CLAUDE.md`, docs, skills, and agents (the app has no push integration).
4. Add skills `spec-propose` and `spec-apply`.
5. `code-reviewer` and `flutter-architect` check work against the change's requirements.
6. `CLAUDE.md`: new product description, link to `specs/`, a *Specs & Docs Workflow* section, updated documentation map.
7. Retire the old plan folders: delete `.claude/plans/` and the root `docs/` (all four plans were already executed) and remove `.claude/plans/` from `.gitignore`.

## Out of scope

- Any change to app code.
- Rewriting doc content beyond merging, de-duplicating, fixing links, and correcting stale facts.
- Capability files (created on demand by `0001`+).

## Impacted capabilities

None (documentation only).
