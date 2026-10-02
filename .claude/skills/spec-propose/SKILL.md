---
name: spec-propose
description: Use when the user asks for a new feature, behavior change, or bug fix in DueDay and no approved spec change exists for it yet — or to complete a draft change in specs/changes/. Creates or completes specs/changes/NNNN-slug/ (proposal.md, spec-delta.md, tasks.md) and stops for user approval. Writes no app code.
---

# Spec Propose

Formats and rules: [specs/README.md](../../../specs/README.md). **Never edit `lib/` or `test/` here.**

1. **Context**
   - Read [specs/product.md](../../../specs/product.md). If the request is *Frozen*, *Later*, or contradicts a decision, say so and ask.
   - Read the related `specs/capabilities/*.md` files (they may not exist yet).
   - Reuse a matching draft in `specs/changes/`, or take the next number.
   - Read the code to ground the facts. Ask the user only for decisions, one at a time, with a recommendation.
2. **Write** `specs/changes/NNNN-slug/`:
   - `proposal.md`: `Status: proposed`, Why (with file refs), What, Out of scope, Impacted capabilities, Docs to update.
   - `spec-delta.md`: requirements under ADDED / MODIFIED (`was: …`) / REMOVED, grouped by capability. Continue ID numbering. At least one testable scenario per requirement.
   - `tasks.md`: small tasks grouped Domain → Data → Presentation → Wiring/l10n → Tests → Docs & specs → Verification, each citing requirement IDs.
   - Bug fix with intended behavior unchanged: skip `spec-delta.md`; `proposal.md` has reproduction + expected behavior; `tasks.md` has a regression test.
3. **Stop:** summarize for the user in their language and ask for approval. Once approved, set `Status: approved`. Next step: [spec-apply](../spec-apply/SKILL.md).
