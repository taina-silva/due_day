# Standard Procedure: Refactor Feature (refactor_feature.md)

This guide describes how to safely refactor existing features in **DueDay** to improve code quality without introducing regressions.

---

## 🛠️ Step-by-Step Refactoring Recipe

### Step 1: Baseline Verification
Ensure the current feature has active tests:
1.  Run the tests for the target feature:
    ```bash
    fvm flutter test test/features/my_feature/
    ```
2.  If tests fail or don't exist, **stop**. Write or fix the baseline tests *before* refactoring the code.

### Step 2: Refactor Code Layer by Layer
Make incremental changes. Run tests after refactoring each layer:

1.  **Refactor Models & serialization:**
    - If modifying fields, update the Freezed annotation.
    - Run code generation:
      ```bash
      fvm flutter pub run build_runner build --delete-conflicting-outputs
      ```
2.  **Refactor Domain Logic:**
    - Update entity properties or UseCase signatures.
    - Update UseCase tests to align with the new signatures.
3.  **Refactor Repositories & DataSources (Error Handling):**
    - Map all raw database/API exceptions to typed domain `Failure`s.
    - Ensure BLoC states propagate `Failure` objects (never raw strings) and the UI localizes them.
4.  **Refactor BLoC & Presentation Widgets:**
    - Clean up layouts and extract complex sub-widgets into smaller files.
    - Ensure design tokens, responsiveness extensions, and localizations are preserved.

### Step 3: Final Verification (Format, Lint, Tests)
Verify that all changes are formatted, compile cleanly, and pass tests:
1. Format all changed files and clean unused imports:
   ```bash
   fvm dart format .
   ```
2. Check for and resolve any linter warnings or errors in changed files:
   ```bash
   fvm flutter analyze
   ```
3. Ensure all tests pass:
   ```bash
   fvm flutter test
   ```
If any checks or tests fail, resolve them before committing the code.
