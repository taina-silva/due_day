# Testing Strategy (testing.md)

This document defines the testing strategy, patterns, tools, and mock configurations for the **DueDay** project.

---

## 🎯 1. Testing Philosophy

We verify system correctness through layered testing. Because we use **Clean Architecture**, we isolate frameworks using interfaces, enabling simple, mock-based unit tests for business logic.

- **Unit Tests (High Priority):** Test Domain UseCases, Data Models/Entities, and Presentation BLoCs in isolation.
  - **Models & Entities:** Every `_model.dart` and `_entity.dart` must have dedicated unit tests. They are not to be left without testing. Tests must cover serialization (`fromJson`/`toJson`), conversions (`fromEntity`/`toEntity`), equality (`Equatable` props), and `copyWith` behavior to verify data mappings.
- **Widget Tests (Medium Priority):** Test individual Design System components and layout screens.
- **Integration Tests (Low Priority):** Test end-to-end user flows (e.g., login to dashboard) on real devices or simulators.

---

## 🧪 2. Unit Testing (Domain & Data)

Unit tests focus on validating logic without database or framework access.

- **Tools:** `flutter_test`, `mocktail` (or `mockito`) for dependency mocking.
- **Error States:** Use Cases must be tested for both success (`Right`) and failure (`Left`) returns.
- **Naming Pattern:** All test descriptions must follow the `given [precondition] when [action] then [expected result]` format.

### Example UseCase Test Blueprint
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/domain/usecases/add_account.dart';
import 'package:due_day/features/accounts/domain/repositories/account_repository.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  late AddAccount usecase;
  late MockAccountRepository mockRepository;

  setUp(() {
    mockRepository = MockAccountRepository();
    usecase = AddAccount(mockRepository);
  });

  test(
    'given account data when addAccount is called then return Right(null)',
    () async {
      // Arrange
      when(() => mockRepository.addAccount(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(testAccount);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.addAccount(testAccount)).called(1);
    },
  );
}
```

---

## 📊 3. BLoC Testing

We test BLoCs by sending events and asserting the exact sequential list of emitted states.
- **Package:** `bloc_test`
- **Pattern:** Use the `blocTest` utility with `given-when-then` formatted descriptions:
```dart
blocTest<AuthBloc, AuthState>(
  'given successful login credentials when LoginEvent is added then emit [AuthLoading, AuthAuthenticated]',
  build: () {
    when(() => mockLoginUseCase(any())).thenAnswer((_) async => Right(testUser));
    return AuthBloc(loginUseCase: mockLoginUseCase);
  },
  act: (bloc) => bloc.add(const AuthSignInEmailEvent(email: 'a@b.com', password: '123')),
  expect: () => [
    AuthLoading(),
    AuthAuthenticated(user: testUser),
  ],
);
```

---

## 🎨 4. Widget Testing

Widget tests assert that design system layouts and page trees render correct parameters and capture user gestures.
- **Theme Injection:** When testing a widget, wrap it in a `MaterialApp` with the `DueDayTheme` and `MultiBlocProvider` to avoid context-resolution crashes.
- **Interaction Testing:** Use `tester.tap()`, followed by `tester.pumpAndSettle()` to let animations finish before checking expectations.

---

## 📂 5. Test Directory Map

The `test/` directory mirrors the `lib/` directory:
```
test/
├── features/
│   ├── auth/
│   │   ├── domain/usecases/
│   │   │   └── sign_in_usecase_test.dart
│   │   ├── data/repositories/
│   │   │   └── auth_repository_impl_test.dart
│   │   └── presentation/bloc/
│   │       └── auth_bloc_test.dart
│   └── accounts/
└── core/
    ├── navigation/
    └── design_system/
```

---

## ⚡ 6. CLI Test Commands

- **Run all tests:**
  ```bash
  fvm flutter test
  ```
- **Run specific test file:**
  ```bash
  fvm flutter test test/features/auth/domain/usecases/sign_in_usecase_test.dart
  ```
- **Check code coverage:**
  ```bash
  fvm flutter test --coverage
  ```

---

## 📈 7. Code Coverage Standards

Every new or modified file must reach a minimum of **80% code coverage** (excluding generated files like `.freezed.dart` or `.g.dart`).

```bash
# Generate visual HTML report
genhtml coverage/lcov.info -o coverage/html
```
Open `coverage/html/index.html` in a browser to review coverage details.

---

## 🔁 8. Testing Order for a New Feature

When implementing a feature, write tests in this order — each phase's mocks feed the next:

```
[Phase 1: Domain UseCases] ➔ [Phase 2: Data/Repository w/ Mocks] ➔ [Phase 3: BLoC (bloc_test)] ➔ [Phase 4: Widget]
```
Resource cleanup: always close stream controllers or manual subscriptions created in `setUp` during `tearDown` to avoid memory leaks.
