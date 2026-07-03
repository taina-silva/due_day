# AI Coding Conventions (ai_coding_conventions.md)

Quick reference guide to ensure that any generated page, widget, or layout conforms to the styling standards and patterns defined in the **DueDay** project.

---

## 📋 Base Prompt

Copy and paste this instruction at the beginning of any screen or widget implementation request:

> When implementing any screen or widget in this Flutter project, you must strictly follow these design conventions:
>
> **Colors** — Use exclusively `DueDayTheme.colors` (`AppColorsSys`). Access them via `colors.resource.primary`, `colors.onDarkBackground`, `colors.lightBackground`, etc. Never use `Colors.white`, `Colors.black`, or raw hex literals.
>
> **Dimensions** — Use `DueDayTheme.dimensions` for all sizes, spacing, margins, border radius, and stroke values:
> - `dimensions.size.*` for fixed component widths/heights.
> - `dimensions.spacing.*` for margins and paddings.
> - `dimensions.radius.*` for rounded corners.
>
> **Responsive Extensions** — Apply `.width` (or `.w`), `.height` (or `.h`), `.scale` (or `.sp`), or `.fontSize` (or `.fs`) to **every** numeric dimensional layout value, using the `NumExtension` utilities. Examples: `spacing.mediumLarge.height`, `size.large.width`, `104.scale`, `16.fontSize`.
>
> **Texts & i18n** — Never use hardcoded literal strings in user-facing widgets. All user-visible strings must come from `AppLocalizations.of(context)`. If a translation key does not exist, define it in both `app_en.arb` and `app_pt.arb` files using the `featureNomeChave` camelCase format (e.g., `splashTagline`), then run `fvm flutter gen-l10n` to regenerate the translation accessors.

---

## 🎨 Colors — `DueDayTheme.colors`

**File:** `lib/core/design_system/theme/app_colors/app_colors.dart`

| Token | Purpose |
|---|---|
| `colors.resource.primary` | Main brand color |
| `colors.resource.primaryWith15Opacity` | Primary color with 15% opacity |
| `colors.resource.primaryWith30Opacity` | Primary color with 30% opacity |
| `colors.resource.secondary` | Secondary brand helper color |
| `colors.resource.neutral` | Muted gray |
| `colors.system.success` | Green (success state feedback) |
| `colors.system.error` | Red (error state feedback) |
| `colors.system.warning` | Yellow (warning alert) |
| `colors.system.info` | Light Blue (informational alert) |
| `colors.lightBackground` | Canvas background for Light Theme |
| `colors.darkBackground` | Canvas background for Dark Theme |
| `colors.lightSurface` | Card/Container background for Light Theme |
| `colors.darkSurface` | Card/Container background for Dark Theme |
| `colors.onLightBackground` | Text/Icon foreground on light backgrounds |
| `colors.onDarkBackground` | Text/Icon foreground on dark backgrounds |

### ✅ Correct Usage
```dart
color: colors.onDarkBackground
color: colors.resource.primary
color: colors.onDarkBackground.withValues(alpha: 0.75)
```

### ❌ Incorrect Usage
```dart
color: Colors.white
color: const Color(0xFF456EFE)
color: Colors.black87
```

---

## 📏 Dimensions — `DueDayTheme.dimensions`

**File:** `lib/core/design_system/theme/app_dimensions/app_dimensions.dart`

### Sizes (`dimensions.size.*`) — returns `double`

```dart
size.small              // 4.0
size.smallMedium        // 8.0
size.medium             // 12.0
size.mediumLarge        // 16.0
size.large              // 20.0
size.largeExtraLarge    // 24.0
size.extraLarge         // 28.0
size.twoExtraLarge      // 36.0
size.twoExtraLargeMedium // 40.0
size.threeExtraLarge    // 64.0
size.iconSmall          // 16.0
size.iconMedium         // 24.0
size.iconLarge          // 32.0
size.buttonSmall        // 40.0
size.buttonMedium       // 48.0
size.buttonLarge        // 56.0
```

### Spacing (`dimensions.spacing.*`) — returns `double`

```dart
spacing.extraSmall          // 2.0
spacing.small               // 4.0
spacing.smallMedium         // 8.0
spacing.medium              // 12.0
spacing.mediumLarge         // 16.0
spacing.large               // 20.0
spacing.largeExtraLarge     // 24.0
spacing.extraLarge          // 28.0
spacing.twoExtraLarge       // 36.0
spacing.twoExtraLargeMedium // 40.0
spacing.threeExtraLarge     // 64.0
spacing.safeBottomNav       // 120.0
```

### Radius (`dimensions.radius.*`) — returns `double`

```dart
radius.small       // 8.0
radius.medium      // 12.0
radius.large       // 16.0
radius.extraLarge  // 20.0
radius.circle      // 999.0
```

### Stroke (`dimensions.stroke.*`) — returns `double`

```dart
stroke.extraSmall       // 0.5
stroke.small            // 1.0
stroke.medium           // 1.5
stroke.large            // 2.0
stroke.extraLarge       // 2.5
stroke.extraExtraLarge  // 3.0
```

---

## 📐 Responsive Extensions — `NumExtension`

**File:** `lib/core/utils/extensions/num_extension.dart`  
**Import:** `import 'package:due_day/core/utils/extensions/num_extension.dart';`

Scales dimension and typography values based on the physical device screen size (relative to a 390×844 canvas ratio).

| Extension | Alias | Usage |
|---|---|---|
| `.width` | `.w` | Widths (horizontal scale) |
| `.height` | `.h` | Heights (vertical scale) |
| `.scale` | `.sp` | Uniform scaling (containers, graphics) |
| `.fontSize` | `.fs` | Font sizes (constrained between 12 and 36) |

### ✅ Correct Usage
```dart
SizedBox(height: spacing.mediumLarge.height)
SizedBox(width: size.large.width)
Container(width: 104.scale, height: 104.scale)
fontSize: size.twoExtraLarge.fontSize
EdgeInsets.symmetric(
  horizontal: spacing.largeExtraLarge.width,
  vertical: spacing.twoExtraLarge.height,
)
```

### ❌ Incorrect Usage
```dart
SizedBox(height: 16)
Container(width: 104, height: 104)
fontSize: 36
EdgeInsets.symmetric(horizontal: 24, vertical: 36)
```

---

## 🌍 Localizations — `AppLocalizations`

**Import:** `import 'package:due_day/core/l10n/app_localizations.dart';`  
**ARB Files:** `lib/core/l10n/app_en.arb` and `lib/core/l10n/app_pt.arb`

### Usage

```dart
final l10n = AppLocalizations.of(context);

Text(l10n.splashTagline)
Text(l10n.loginSubmitButton)
```

### Key Naming Conventions

Keys follow camelCase naming formatted as `featureNomeChave`:

```
splash       → splashAppName, splashTagline
login        → loginSubtitle, loginSubmitButton, loginEmailLabel
signup       → signupTitle, signupNameHint
dashboard    → dashboardGreeting, dashboardMonthlySummary
categories   → categoriesTitle, categoriesEmpty
profile      → profileTitle, profileLogOut
```

### How to Add a New Translation Key

1. Add the key and description in `app_en.arb`:
```json
"featureNewKey": "English text"
```

2. Add the matching key in `app_pt.arb`:
```json
"featureNewKey": "Texto em português"
```

3. Regenerate the localization bindings:
```bash
fvm flutter gen-l10n
```

4. Reference the key in code:
```dart
l10n.featureNewKey
```

---

## 🏗️ Structure of a Widget — Complete Template

```dart
import 'package:flutter/material.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Retrieve all theme design tokens
    final colors = DueDayTheme.colors;
    final typography = DueDayTheme.typography;
    final size = DueDayTheme.dimensions.size;
    final spacing = DueDayTheme.dimensions.spacing;
    final radius = DueDayTheme.dimensions.radius;

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

---

## ⚡ Checklist

Before declaring a layout complete, verify:

- [ ] No raw `Colors.*` — only `DueDayTheme.colors.*`
- [ ] No hardcoded dimensions — only `DueDayTheme.dimensions.*`
- [ ] All numeric layouts scale with `.width`, `.height`, `.scale`, or `.fontSize`
- [ ] All user-facing texts utilize `l10n.*` properties
- [ ] New keys are declared in both English and Portuguese ARB files and generated
- [ ] `dart analyze` reports zero warnings/errors
