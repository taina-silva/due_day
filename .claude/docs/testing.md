# Testing

## Rules

- Tools: `flutter_test`, `mocktail`, `bloc_test`.
- Test names: `given <precondition> when <action> then <result>`. In spec changes, prefix with the requirement ID (`'IMP-012: given …'`).
- **80% coverage** on every new or modified file (generated files excluded).
- Every `*_model.dart` and `*_entity.dart` has tests: `fromJson`/`toJson`, `fromEntity`/`toEntity`, equality, `copyWith`.
- Use cases: test both `Right` and `Left`.
- `test/` mirrors `lib/`.
- Order for a new feature: Domain → Data → BLoC → Widget.
- Close stream controllers and subscriptions in `tearDown`.

## Use case

```dart
class MockAccountRepository extends Mock implements AccountRepository {}

test('given valid account when addAccount is called then returns Right', () async {
  when(() => repo.addAccount(any())).thenAnswer((_) async => const Right(null));

  final result = await usecase(tAccount);

  expect(result, const Right(null));
  verify(() => repo.addAccount(tAccount)).called(1);
});
```

## BLoC

Assert the exact sequence of states. Load and Action blocs get **separate** test files.

```dart
blocTest<CategoryActionBloc, CategoryActionState>(
  'given add fails when AddCategoryEvent is added then emits [InProgress, Error]',
  build: () {
    when(() => mockAddCategory(any())).thenAnswer((_) async => const Left(ServerFailure('x')));
    return bloc;
  },
  act: (b) => b.add(AddCategoryEvent(tCategory)),
  expect: () => [CategoryActionInProgress(), const CategoryActionError(failure: ServerFailure('x'))],
);
```

Always assert `XActionInProgress`: without it, `Equatable` swallows two identical consecutive errors.

## Widgets

- Wrap in `MaterialApp` with the theme, localizations, and required `BlocProvider`s.
- After `tester.tap()`, call `pumpAndSettle()`.
- False `RenderFlex` overflows on tight buttons? Load the real font in `setUpAll` with `FontLoader('Sofia Sans')`.
- Find toasts by `Key('app_messenger_toast')`.

### Mutating bottom sheet

Control the mock Action Bloc with `whenListen` and emit after tapping save:

```dart
stateController = StreamController<CategoryActionState>.broadcast();
whenListen(mockActionBloc, stateController.stream, initialState: CategoryActionInitial());

// error → sheet stays open + toast
stateController.add(const CategoryActionError(failure: ServerFailure('x')));
await tester.pumpAndSettle();
expect(find.byType(AddEditCategoryBottomSheet), findsOneWidget);

// success → sheet closes: stateController.add(CategoryActionSuccess()) → findsNothing
```

## Commands

```bash
fvm flutter test                       # all
fvm flutter test path/to/file_test.dart
fvm flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
```
