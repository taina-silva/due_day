# Coding Standards

## Naming

- Files: `snake_case` with a role suffix: `_entity`, `_model`, `_remote_data_source` / `_local_data_source`, `_repository` / `_repository_impl`, `_bloc` / `_event` / `_state` (or `_load_*` + `_action_*`), `_page`, `_widget`, `_injection`.
- Classes: `UpperCamelCase`, matching the suffix (`AuthRepositoryImpl`). Variables and functions: `lowerCamelCase`.
- English everywhere in code and docs. pt-BR only in `app_pt.arb`.

## UI

Design tokens, responsive sizes, and `AppMessenger`: [design_system.md](design_system.md). Texts: [localization.md](localization.md). New screens: [create-screen](../skills/create-screen/SKILL.md).

## Error handling

- **DataSource:** throws `ServerException('Technical English message.', e.code)`.
- **Repository:** catches it, logs it ([observability.md](observability.md)), maps the code to a typed `Failure`, returns `Left`.
- **BLoC:** `result.fold((f) => emit(XError(failure: f)), (v) => emit(XLoaded(v)))`.
- **UI:** `failure.toLocalizedString(context)` (extension in `presentation/utils/`).
- **Fallbacks per operation:** reads → `ServerFailure`; `add/update` → `XSaveFailure`; `delete` → `XDeleteFailure`, each with its own l10n key. Reference: `accounts` (`account_failures.dart`).
- Refactoring a feature includes migrating its error handling to this pattern.

```dart
} on ServerException catch (e) {
  if (e.code == 'user-not-found') return const Left(InvalidCredentialsFailure());
  return Left(ServerFailure(e.message));
}
```

## Control flow

Use `switch` (not `if`/`else if`) when branching 3+ ways on the same value or type:

```dart
switch (this) {
  case AccountNotFoundFailure(): return l10n.accountsErrorNotFound;
  default: return l10n.accountsErrorFallback;
}
```

## Imports

Relative inside the same feature; `package:due_day/...` for everything else. Order: SDK → third-party → `due_day` → relative.

## Environment

- FVM, Flutter `3.41.6`, Dart `3.11.4`. Android and iOS only.
- Code generation:
  ```bash
  fvm flutter pub run build_runner build --delete-conflicting-outputs
  fvm flutter gen-l10n
  ```

## Before finishing

- [ ] No `Colors.*`, hardcoded sizes, `'assets/…'` paths, or raw `SnackBar`.
- [ ] Numeric layout values use `.w` / `.h` / `.sp` / `.fs`.
- [ ] All texts come from `AppLocalizations`.
- [ ] No raw exceptions reach pages.
- [ ] `fvm dart format .` and `fvm flutter analyze` with zero issues.
