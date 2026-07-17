---
name: add-test-coverage-existing-feature
description: Use when a DueDay feature already exists but is missing unit/BLoC/widget test coverage. Covers running the coverage analyzer, filling UseCase/BLoC/widget test gaps, and the final format/lint pass.
---

# Standard Procedure: Add Test Coverage

This guide describes how to identify coverage gaps and write automated tests for existing features.

---

## 🛠️ Step-by-Step Coverage Improvement Recipe

### Step 1: Run Coverage Analyzer
Generate the coverage matrix:
```bash
fvm flutter test --coverage
```
This generates `coverage/lcov.info`. Use coverage extensions or tools (e.g. `lcov` html report generator) to inspect uncovered files.

### Step 2: Write Missing UseCase Tests
1.  Navigate to `test/features/{feature}/domain/usecases/`.
2.  If the file doesn't exist, create `{usecase_name}_test.dart`.
3.  Inject a Mock Repository using `mocktail`:
    ```dart
    class MockFeatureRepository extends Mock implements FeatureRepository {}
    ```
4.  Test all logical paths (e.g. invalid inputs, error returns, standard success).

### Step 3: Write Missing BLoC Tests
1.  Navigate to `test/features/{feature}/presentation/bloc/`.
2.  Create `{feature_name}_bloc_test.dart`.
3.  Verify the BLoC maps events to state transitions.
4.  Write assertions for:
    - Initial state.
    - Emitted states list on successful UseCase execution.
    - Emitted states list on failure UseCase execution.

### Step 4: Write Widget Component Tests
1.  Identify custom components under `presentation/widgets/`.
2.  Write widget tests rendering the components. Verify styling tokens, labels, and gesture events:
    ```dart
    testWidgets('AppTextButton renders label and registers tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: AppTextButtonPrimary(
            label: 'Submit',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      await tester.tap(find.text('Submit'));
      expect(tapped, isTrue);
    });
    ```

### Step 5: Format and Lint Checks
Before concluding the testing task:
1. Run `fvm dart format .` to format the test files and remove unused imports.
2. Run `fvm flutter analyze` to verify that no new linter warnings or errors have been introduced in the test files or modified source code. Ensure all warnings (e.g. subtype_of_sealed_class) are resolved or explicitly ignored using standard directives.
