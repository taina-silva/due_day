---
name: spec-apply
description: Use when implementing an approved DueDay spec change (specs/changes/NNNN-slug/ with Status approved or in-progress). Implements tasks.md in order using the existing implementation skills, keeps the checklist current, and archives the change by merging its spec delta into specs/capabilities/ and updating affected docs.
---

# Spec Apply

Rules: [specs/README.md](../../../specs/README.md).

1. **Load:** open `proposal.md`. If it isn't `approved` / `in-progress`, stop and use [spec-propose](../spec-propose/SKILL.md). Read `spec-delta.md` and `tasks.md`. Set `Status: in-progress`.
2. **Implement** tasks in order:
   - Use the matching recipe: `create-usecase`, `create-model`, `create-datasource`, `create-repository`, `create-firestore-query`, `create-bloc`, `create-screen`, `add-route`, `add-notification`, `add-test-coverage-existing-feature`.
   - Scenarios are the acceptance criteria; name tests after their IDs.
   - Tick each task as soon as it's verified.
   - Out-of-scope findings go under `## Follow-ups` in `tasks.md`, not into code. No unrelated refactors.
   - Wrong or ambiguous requirement → ask the user, then update `spec-delta.md`.
3. **Verify:** `fvm dart format .` · `fvm flutter analyze` (zero issues) · `fvm flutter test`. Then run the `code-reviewer` agent and fix blocking findings.
4. **Archive:**
   - Merge the delta into `specs/capabilities/` (create the file if needed; ADDED → append, MODIFIED → replace, REMOVED → delete).
   - Update `product.md` if scope changed, and the `.claude/docs/` listed in the proposal.
   - Set `Status: done` and move the folder to `specs/changes/archive/`.
   - Tell the user what shipped, the follow-ups, and what to test on the device.

Code, specs, and docs go in the same commit. Commit only when the user asks.
