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
  - Blocs: `*_bloc.dart`, `*_event.dart`, and `*_state.dart`
  - Pages/Widgets: `*_page.dart` (screens) and `*_widget.dart` (sub-components)
  - Injection: `*_injection.dart`

### Class Names
- Must be written in `UpperCamelCase`.
- Suffixes should match their file suffixes: e.g., `UserEntity`, `UserModel`, `AuthRepositoryImpl`, `AuthBloc`.

### Variables & Functions
- Must be written in `lowerCamelCase`.

---

## 🎨 2. Design System Tokens & Responsiveness

Never hardcode styling assets (colors, fonts, paddings, margin size, radius) within layouts. Always utilize `DueDayTheme` through the `BuildContext` extension inside build methods.

### 2.1. Colors
Access colors via `context.colors` (or `DueDayTheme.colors` if `BuildContext` is not available). Do not use `Colors.white`, `Colors.black`, or raw hex values.
- **Example:**
  ```dart
  color: context.colors.resource.primary
  color: context.colors.lightBackground
  ```

### 2.2. Dimensions
Access dimensions via `context.dimensions` or the specific shortcuts (`context.spacing`, `context.radius`, `context.sizes`, `context.stroke`):
- `sizes` (e.g., `context.sizes.iconMedium`)
- `spacing` (e.g., `context.spacing.mediumLarge`)
- `radius` (e.g., `context.radius.large`)
- `stroke` (e.g., `context.stroke.small`)

### 2.3. Responsive Layout Extensions (`NumExtension`)
Always apply responsive scaling to physical layout values using the extension located in `lib/core/utils/extensions/num_extension.dart`:
- `.width` (or `.w`) — Scale relative to device width.
- `.height` (or `.h`) — Scale relative to device height.
- `.scale` (or `.sp`) — Uniform scaling for graphic elements/containers.
- `.fontSize` (or `.fs`) — Responsive font size scaling.

**Example:**
```dart
SizedBox(height: spacing.mediumLarge.height)
SizedBox(width: size.large.width)
Container(width: 104.scale, height: 104.scale)
style: TextStyle(fontSize: size.twoExtraLarge.fontSize)
```

---

## 🌍 3. Localization Standards (i18n)

User-facing texts must be localized. Never use literal strings inside widget layouts.
- **Import:** `import 'package:due_day/core/l10n/app_localizations.dart';`
- **Usage:**
  ```dart
  final l10n = AppLocalizations.of(context);
  Text(l10n.loginSubmitButton)
  ```
- **Naming Translation Keys:** Use `featureNomeChave` in camelCase:
  - E.g., `loginEmailLabel`, `signupTitle`, `dashboardGreeting`.
- Add new translations in both `lib/core/l10n/app_en.arb` and `lib/core/l10n/app_pt.arb` files, then trigger code generation:
  ```bash
  fvm flutter gen-l10n
  ```

---

## ⚡ 4. Error Handling Pattern (Functional Style)

DueDay implements functional error handling using `fpdart` and the `Either<L, R>` type to prevent unchecked exceptions from reaching the UI.

- **Data Layer:** Remote/Local DataSources throw raw exceptions (e.g., `ServerException`).
- **Repository Implementation:** Captures exceptions using `try-catch` blocks and returns an instance of `Left(Failure)`:
  ```dart
  @override
  Future<Either<Failure, UserEntity>> signIn(String email, String password) async {
    try {
      final userModel = await dataSource.signInWithEmail(email, password);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
  ```
- **BLoC & UI Layer:** The BLoC invokes the UseCase and folds the returned `Either` state:
  ```dart
  final result = await signInUseCase(params);
  result.fold(
    (failure) => emit(AuthError(message: failure.message)),
    (user) => emit(AuthAuthenticated(user: user)),
  );
  ```

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

## ⚡ 7. Formatting Checklist

Before completing files:
- [ ] No raw `Colors.*` — only `DueDayTheme.colors.*` (or `context.colors.*`)
- [ ] No hardcoded dimensions — only `DueDayTheme.dimensions.*` (or `context.dimensions.*`)
- [ ] All numeric layouts scale with `.width`, `.height`, `.scale`, or `.fontSize`.
- [ ] All texts retrieved via `AppLocalizations`.
- [ ] No raw exceptions bubble up to pages.
- [ ] Run `fvm flutter analyze` to confirm no errors.

---

## 🤖 8. AI Guidelines & Screen Template

When generating layout files, pages, or custom widgets, AI assistants must strictly conform to the styling conventions, localization standards, and architecture layers. 

### 8.1. AI Context Base Prompt
Use the following prompt to configure code generation rules:
> **Colors** — Use exclusively the theme colors via `context.colors` (`AppColorsSys`). Access them via `colors.resource.primary`, `colors.onDarkBackground`, etc. Never use `Colors.white`, `Colors.black`, or raw hex literals.
>
> **Dimensions** — Use `context.dimensions` (or its direct shortcuts) for all sizes, spacing, margins, border radius, and stroke values:
> - `context.sizes.*` for fixed component widths/heights.
> - `context.spacing.*` for margins and paddings.
> - `context.radius.*` for rounded corners.
>
> **Responsive Extensions** — Apply `.width` (or `.w`), `.height` (or `.h`), `.scale` (or `.sp`), or `.fontSize` (or `.fs`) to **every** numeric dimensional layout value, using the `NumExtension` utilities.
>
> **Texts & i18n** — Never use hardcoded literal strings in user-facing widgets. All user-visible strings must come from `AppLocalizations.of(context)`.

### 8.2. Base Widget Structure Template
```dart
import 'package:flutter/material.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Retrieve all theme design tokens using BuildContext extension
    final colors = context.colors;
    final typography = context.typography;
    final size = context.sizes;
    final spacing = context.spacing;
    final radius = context.radius;

    // 2. Retrieve localization dictionary
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.lightBackground,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.largeExtraLarge.width,
          vertical: spacing.twoExtraLarge.height,
        ),
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo/logo.png',
              width: 104.scale,
              height: 104.scale,
            ),
            SizedBox(height: spacing.mediumLarge.height),
            Text(
              l10n.exampleTitle,
              style: typography.headline.large.copyWith(
                color: colors.onLightBackground,
                fontSize: size.twoExtraLarge.fontSize,
              ),
            ),
            SizedBox(height: spacing.small.height),
            Text(
              l10n.exampleSubtitle,
              style: typography.body.medium.copyWith(
                color: colors.onLightBackground.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

