---
name: review-feature
description: Use as a checklist when reviewing a DueDay feature implementation or code submission. Covers architectural integrity, design-system/token compliance, clean-code/localization rules, and test/analyze checks.
---

# Review Feature

## Spec
- [ ] Every requirement and scenario in the change's `spec-delta.md` is implemented and tested.
- [ ] Affected `specs/` and `.claude/docs/` files are updated in the same change.

## Architecture ([architecture.md](../../docs/architecture.md))
- [ ] UI → BLoC → UseCase only; no repository, datasource, or Firebase access from UI.
- [ ] Domain is pure Dart. DataSources throw; repositories return `Either<Failure, T>`.
- [ ] Every repository catch block logs with `tag` and never logs entities or amounts ([observability.md](../../docs/observability.md)).
- [ ] Stream + mutations → `XLoadBloc` + `XActionBloc`; error states named `XError`; `XActionInProgress` emitted before results.
- [ ] Mutating bottom sheets pop only on success and show `AppMessenger.showError` on error.
- [ ] Fallback failures differ per operation (read / save / delete) ([coding_standards.md](../../docs/coding_standards.md#error-handling)).

## UI ([design_system.md](../../docs/design_system.md))
- [ ] No `Colors.*`, hex literals, hardcoded sizes, `'assets/…'` paths, or raw `SnackBar`.
- [ ] Numeric layout values use `.w` / `.h` / `.sp` / `.fs`.
- [ ] Touch targets ≥ 44x44; WCAG AA contrast.

## Code
- [ ] `snake_case` files; every text from `AppLocalizations` (keys in both `.arb` files).
- [ ] `switch` instead of 3+ branch `if` chains on the same value.
- [ ] No unused imports, commented-out code, or `print`.

## Checks
- [ ] `fvm dart format .` · `fvm flutter analyze` (zero issues) · `fvm flutter test` (green, success and failure paths covered).
