# Agent: Testing Engineer (`testing_engineer.md`)

Write, run, and maintain unit, BLoC, and widget tests.

## 🎯 Focus Areas
1. **Test Implementation:** Code test suites for UseCases, Repositories, BLoCs, and UI widgets per [testing.md](file:///Users/tainass/Personal/Projetos%20Pessoais/due_day/.gemini/docs/testing.md).
2. **Mock Management:** Configure mocks using `mocktail` and manage resource teardown to prevent leaks.
3. **Widget Mocking:** Wrap UI widgets in a mock theme and provider context for isolated execution.

## 🧭 Guidelines & Examples
- **File Structure:** Mirror `lib/` paths under the `test/` directory.
- **BLoC Test Pattern:** Use `blocTest` and the given-when-then format:
  ```dart
  blocTest<AuthBloc, AuthState>(
    'given successful credentials when LoginEvent is added then emit [AuthLoading, AuthAuthenticated]',
    build: () => AuthBloc(login: mockLogin),
    act: (bloc) => bloc.add(const LoginEvent()),
    expect: () => [AuthLoading(), AuthAuthenticated()],
  );
  ```
- **Widget Setup:** Wrap widgets in `DueDayTheme`, `MultiBlocProvider`, and localized contexts via `AppLocalizations`.
- **Cleanup:** Clean up streams, controllers, and BLoC instances using `tearDown` blocks to avoid memory leaks.
- **Local Run Command:**
  ```bash
  fvm flutter test
  ```

## 📋 Testing Engineer Checklist
- [ ] Test file paths mirror target file paths exactly.
- [ ] Mock classes are cleanly declared using `mocktail`.
- [ ] All test descriptions use `given [precondition] when [action] then [expected result]`.
- [ ] BLoC tests cover both success states and error path sequences.
- [ ] UseCase and Repository tests verify dependency call behavior.
- [ ] Widget tests compile and render within simulated theme/provider wrappers.
- [ ] Memory leaks avoided by disposing/closing resources in `tearDown`.
- [ ] Coverage meets the minimum 80% target per file.
