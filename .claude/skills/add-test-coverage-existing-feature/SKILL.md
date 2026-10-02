---
name: add-test-coverage-existing-feature
description: Use when a DueDay feature already exists but is missing unit/BLoC/widget test coverage. Covers running the coverage analyzer, filling UseCase/BLoC/widget test gaps, and the final format/lint pass.
---

# Add Test Coverage

Patterns and examples: [testing.md](../../docs/testing.md). Target: 80% per file.

1. **Find gaps:** `fvm flutter test --coverage`, then `genhtml coverage/lcov.info -o coverage/html`.
2. **Models/entities:** serialization, conversion, equality, `copyWith`.
3. **Use cases** (`test/features/<f>/domain/usecases/`): mock the repository with `mocktail`; cover success, failure, and edge inputs.
4. **BLoCs** (`…/presentation/bloc/`): initial state plus state sequences on success and failure. Load and Action blocs in separate files.
5. **Widgets** (`…/presentation/widgets/`): labels, taps, and states. Mutating bottom sheets: both branches.
6. **Finish:** `fvm dart format .` and `fvm flutter analyze` with zero issues.
