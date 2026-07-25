# Coding Standards (coding_standards.md)

This document outlines the coding standards, naming conventions, directory organization, error handling patterns, and code styles for the **DueDay** project.

---

## 📋 1. Naming & File Conventions

All source files, variables, classes, and directories must follow these conventions:

### File Names
- **Rule:** Must be written in `snake_case`.
- **Suffixes:** Files must end with their responsibility:
  - Entities: `*_entity.dart` (e.g., `user_entity.dart`)
  - Models: `*_model.dart` (e.g., `user_model.dart`)
  - DataSources: `*_remote_data_source.dart` or `*_local_data_source.dart`
  - Repositories: `*_repository.dart` (interface) and `*_repository_impl.dart` (implementation)
  - Blocs: `*_bloc.dart`, `*_event.dart`, and `*_state.dart`. For features with a real-time list stream **and** mutating actions, split into `*_load_bloc.dart`/`*_load_event.dart`/`*_load_state.dart` plus `*_action_bloc.dart`/`*_action_event.dart`/`*_action_state.dart` — this is the default, not a special case. See [architecture.md §1.3](architecture.md#load-bloc--action-bloc-separation-standard-for-streamed-features) and [create-bloc](../skills/create-bloc/SKILL.md).
  - Pages/Widgets: `*_page.dart` (screens) and `*_widget.dart` (sub-components)
  - Injection: `*_injection.dart`

### Class Names
- Must be written in `UpperCamelCase`.
- Suffixes should match their file suffixes: e.g., `UserEntity`, `UserModel`, `AuthRepositoryImpl`, `AuthBloc`.

### Variables & Functions
- Must be written in `lowerCamelCase`.

---

## 🎨 2. Design System Tokens & Responsiveness

Never hardcode styling assets (colors, fonts, paddings, margins, radius, `'assets/...'` paths) or call `ScaffoldMessenger`/`SnackBar` directly. Always go through `DueDayTheme` via the `BuildContext` extension, and apply `.w`/`.h`/`.sp`/`.fs` (`NumExtension`) to every numeric layout value.

Full token catalog (colors, typography, dimensions, images, messenger) lives in [design_system.md](design_system.md).

---

## 🌍 3. Localization Standards (i18n)

User-facing texts must be localized — never literal strings inside widget layouts. Retrieve via `AppLocalizations.of(context)`; add new keys to both `app_en.arb` and `app_pt.arb`.

Key naming rules, ARB catalog structure, and the full addition workflow live in [localization.md](../references/localization.md).

---

## ⚡ 4. Error Handling Pattern (Functional Style & i18n localization)

DueDay implements functional error handling using `fpdart` and the `Either<L, R>` type to prevent unchecked exceptions from reaching the UI, while prioritizing English for technical logging and using localization at the Presentation layer.

- **Refactoring Requirement:** Any feature refactoring *must* include refactoring its error handling. Migrate legacy raw strings/exceptions to the typed `Failure` + i18n structure.

- **Data Layer:** Remote/Local DataSources throw raw exceptions (e.g., `ServerException`). 
  - **Rule:** Messages passed to exceptions must be technical English strings (for debugging/Crashlytics/Sentry logs) and include an optional infrastructure error code (`e.code`).
  - **Example:** `throw ServerException('Failed to fetch user.', e.code);`

- **Repository Implementation:** Captures exceptions using `try-catch` blocks, maps the exception code to specific domain-level `Failure` subclasses, and returns an instance of `Left(Failure)`:
  ```dart
  @override
  Future<Either<Failure, UserEntity>> signIn(String email, String password) async {
    try {
      final userModel = await dataSource.signInWithEmail(email, password);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return const Left(InvalidCredentialsFailure());
      }
      return Left(ServerFailure(e.message));
    }
  }
  ```

- **BLoC & UI Layer:** The BLoC invokes the UseCase, folds the returned `Either` state, and emits the failure object directly:
  ```dart
  final result = await signInUseCase(params);
  result.fold(
    (failure) => emit(AuthError(failure: failure)),
    (user) => emit(AuthAuthenticated(user: user)),
  );
  ```
  In the UI, display the error utilizing `failure.toLocalizedString(context)` to resolve the correct localization key.

---

## 📂 5. Import Standards

Ensure clean imports:
- **Relative Imports:** Use relative paths when importing files within the same feature.
- **Package Imports:** Use `package:due_day/...` when referencing core modules, other features, or external plugins.
- Group imports logically:
  1. Flutter and Dart SDK packages.
  2. Third-party packages (e.g., `flutter_bloc`, `fpdart`).
  3. DueDay package imports (e.g., `package:due_day/core/...`).
  4. Relative feature imports.

---

## ⚙️ 6. Environment & Code Generation

### 6.1. Environment & Target Platforms
To prevent build conflicts, the project enforces locked versions and specific platforms:
- **Flutter Version Manager (FVM):** Used to pin and manage the Flutter SDK.
- **Flutter SDK Version:** `3.41.6` (Stable Channel).
- **Dart SDK Version:** `3.11.4` (defined via SDK constraint `sdk: ">=3.10.4 <4.0.0"` in `pubspec.yaml`).
- **Target Platforms:** Android (smartphones and tablets) and iOS (iPhones and iPads) only. Platforms such as Web, macOS, Windows, or Linux are not supported and their respective native directories are removed.

### 6.2. Code Generation Commands
The project relies on `build_runner` and Flutter's localization tools to compile code-generated components. Use the following commands:

```bash
# Run a single build, resolving conflicting outputs automatically
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Run in watcher mode to rebuild automatically on file saves
fvm flutter pub run build_runner watch --delete-conflicting-outputs

# Generate localization assets (i18n)
fvm flutter gen-l10n
```

---

## ⚡ 7. Formatting & Code Quality Checklist

Before completing or committing changes:
- [ ] No raw `Colors.*` — only `DueDayTheme.colors.*` (or `context.colors.*`)
- [ ] No hardcoded dimensions — only `DueDayTheme.dimensions.*` (or `context.dimensions.*`)
- [ ] All numeric layouts scale with `.width`, `.height`, `.scale`, or `.fontSize`.
- [ ] All texts retrieved via `AppLocalizations`.
- [ ] No raw `'assets/...'` path strings — only `AppImages` via `AppImageWidget` (or `AppIcons` for custom SVG icons).
- [ ] No raw `ScaffoldMessenger`/`SnackBar` calls — only `AppMessenger.showSuccess/showError/showInfo`.
- [ ] No raw exceptions bubble up to pages.
- [ ] Run `fvm dart format .` to format all changed files and remove unused imports.
- [ ] Run `fvm flutter analyze` to verify and resolve all warnings and errors in changed files (ensuring zero issues).

---

## 🤖 8. Generating Pages & Widgets

Building a new screen or widget is covered end-to-end by the [create-screen](../skills/create-screen/SKILL.md) skill (BLoC-integrated template) and the [design_system.md §8](design_system.md#-8-complete-layout-integration-template) full-page example. Both already encode the rules from §2–§3 above — no separate AI prompt needed.

