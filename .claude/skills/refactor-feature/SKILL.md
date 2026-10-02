---
name: refactor-feature
description: Use when safely refactoring an existing DueDay feature without introducing regressions. Covers baseline test verification, layer-by-layer refactor order (models → domain → data → presentation), and final format/lint/test checks.
---

# Refactor Feature

> Until the MVP definition of done is met ([specs/product.md](../../../specs/product.md)), refactor only what an active spec change requires.

1. **Baseline:** `fvm flutter test test/features/<feature>/`. Failing or missing tests? Fix or write them **before** refactoring.
2. **Layer by layer**, running tests after each:
   1. Models: update `freezed`, then run `build_runner`.
   2. Domain: entities, use case signatures, and their tests.
   3. Data: map exceptions to typed `Failure`s ([coding_standards.md](../../docs/coding_standards.md#error-handling)).
   4. Presentation: blocs emit `Failure` (never strings); extract large widgets; keep tokens and l10n.
3. **Finish:** `fvm dart format .` · `fvm flutter analyze` · `fvm flutter test`, all green.
