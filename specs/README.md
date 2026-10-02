# Specs

Spec-driven development: every behavior change is written down, approved, then implemented, and the spec stays in sync with the code.

| Path | Holds |
| :--- | :--- |
| [`product.md`](product.md) | Vision, scope, decisions, glossary |
| `capabilities/` | How each area behaves **today**. One file per area, created by the first change that touches it. |
| `changes/NNNN-slug/` | An upcoming change: `proposal.md`, `spec-delta.md`, `tasks.md` |
| `changes/archive/` | Completed changes |

`specs/` = **what/why**. `.claude/docs/` = **how**. Link between them; never copy.

## Lifecycle

1. **Propose** with `/spec-propose` → `Status: proposed`
2. **Approve** (by the user) → `Status: approved`. No code before this.
3. **Apply** with `/spec-apply` → `Status: in-progress`
4. **Archive**: merge the delta into `capabilities/`, update `product.md` and docs if needed, move to `archive/` → `Status: done`

The status is the first line after the title in `proposal.md`.

- **Bug fix** (code wrong, spec right): `proposal.md` (reproduction + expected behavior) + `tasks.md` with a regression test. No `spec-delta.md`.
- **No change needed:** copy/translation, visual-only tweaks, typos, dependency bumps.

## Capability format

```markdown
# Statement import

## Purpose
What this area does for the user.

## Requirements

### IMP-001: Duplicate items are skipped
Items whose external id already exists are marked "already imported" and not saved again.

#### Scenario: re-importing the same file
- **Given** a file was imported before
- **When** it is imported again
- **Then** every item is marked "already imported" and nothing is created

## Out of scope
- …
```

**ID prefixes:** `IMP` import · `DSH` dashboard · `TRX` transactions · `CAT` categories · `ACC` accounts · `SCH` schedule & reminders · `SET` settings. IDs are never reused. Tests may cite them (`'IMP-001: given …'`).

`spec-delta.md` uses the same format under `ADDED`, `MODIFIED` (with `was: …`), and `REMOVED`.

## Rules

1. Every behavior change goes through a change (exceptions above).
2. Code, specs, and docs change in the **same commit**.
3. Archiving = delta merged into `capabilities/` (+ `product.md` if scope changed).
4. `.claude/docs/` changes only when the *how* changes, inside that change.
5. One source per topic.
6. Review blocks on missing requirements or stale specs/docs.
