# Standard Procedure: Add Test Coverage (add_test_coverage_existing_feature.md)

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
