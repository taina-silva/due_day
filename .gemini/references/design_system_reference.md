# Design System Technical Reference (design_system_reference.md)

Detailed implementation reference for the **DueDay** Design System, focusing on tokens, responsive calculations, widget properties, and integration patterns.

---

## 🎯 Overview

The Design System is accessed globally via the static **`DueDayTheme`** class, or inside build methods via the **`BuildContext` extension** (recommended):

### 1. BuildContext Extension Getters (Recommended)
- **Colors:** `context.colors`
- **Typography:** `context.typography`
- **Dimensions:** `context.dimensions`
- **Spacing:** `context.spacing`
- **Radius:** `context.radius`
- **Sizes:** `context.sizes`
- **Stroke:** `context.stroke`

### 2. Theme-Adaptive Color Helpers
- `context.isDarkMode` (bool)
- `context.scaffoldBackgroundColor` (Color)
- `context.surfaceColor` (Color)
- `context.onSurfaceColor` (Color)
- `context.onSurfaceVariantColor` (Color)
- `context.primaryColor` (Color)
- `context.errorColor` (Color)

### 3. Static Gateways (No Context)
- **Colors:** `DueDayTheme.colors`
- **Typography:** `DueDayTheme.typography`
- **Dimensions:** `DueDayTheme.dimensions` (spacings, radii, sizes, stroke widths)

---

## 📂 Design System Folder Structure

```
lib/core/design_system/
├── components/
│   ├── avatar/
│   ├── buttons/
│   │   ├── app_text_button.dart       # Primary, Secondary, and Tertiary text buttons
│   │   ├── app_icon_button.dart       # Action icon buttons
│   │   └── index.dart
│   ├── cards/
│   │   ├── app_card.dart
│   │   └── index.dart
│   ├── form_fields/
│   │   ├── app_text_field.dart        # Central text fields with validation
│   │   ├── app_dropdown_field.dart
│   │   └── index.dart
│   ├── loading/
│   │   ├── circular_loading_on_primary.dart
│   │   ├── circular_loading_primary.dart
│   │   └── index.dart
│   ├── messenger/
│   │   ├── messenger.dart             # Standard SnackBars and dialog alerts
│   │   └── index.dart
│   ├── structure/
│   │   ├── custom_scaffold.dart       # Adaptive scaffold matching theme settings
│   │   ├── custom_app_bar.dart        # Top app bar with pop routing integration
│   │   ├── custom_app_bottom_nav_bar.dart
│   │   └── index.dart
│   └── design_system.dart             # Unified exports manifest
```

---

## 🎨 Colors

Colors are grouped semantically into **Resource (Brand)** and **System (Feedback)** palettes.

### 1. Resource Colors (Brand Palette)
```dart
DueDayTheme.colors.resource.primary                 // Main signature blue (#456EFE)
DueDayTheme.colors.resource.secondary               // Brand helper secondary color
DueDayTheme.colors.resource.neutral                 // Muted gray
DueDayTheme.colors.resource.primaryWith30Opacity    // Primary blue with 30% alpha
DueDayTheme.colors.resource.primaryWith15Opacity    // Primary blue with 15% alpha
```

### 2. System Colors (Feedback Palette)
```dart
DueDayTheme.colors.system.success                   // Green (#13C999) for success feedbacks
DueDayTheme.colors.system.error                     // Red (#FF6363) for error/alert states
DueDayTheme.colors.system.warning                   // Yellow for warnings
DueDayTheme.colors.system.info                      // Light Blue for information states
```

### 3. Background & Surface Colors (Theme Adaptation)
```dart
DueDayTheme.colors.lightBackground                  // Light theme canvas background (white)
DueDayTheme.colors.darkBackground                   // Dark theme canvas background (dark gray)
DueDayTheme.colors.lightSurface                     // Light theme card/container surface
DueDayTheme.colors.darkSurface                      // Dark theme card/container surface

DueDayTheme.colors.onLightBackground                // Dark foreground text on light canvases
DueDayTheme.colors.onDarkBackground                 // Light foreground text on dark canvases
```

### Example Usage
```dart
import 'package:due_day/core/design_system/theme/theme.dart';

Container(
  color: DueDayTheme.colors.resource.primary,
  child: Text(
    'Secure Account',
    style: TextStyle(color: DueDayTheme.colors.onDarkBackground),
  ),
)
```

---

## 🔤 Typography

DueDay standardizes on the **Sofia Sans** Google Font, configured in three weight variants:
- **Regular (400):** General body copy.
- **Medium (500):** UI controls, labels, and highlighted indicators.
- **Semibold (600):** Section headings and titles.

### Font Scales

#### Headline (Primary Screen Titles)
- `DueDayTheme.typography.headline.small` (24px, Semibold)
- `DueDayTheme.typography.headline.medium` (32px, Semibold)
- `DueDayTheme.typography.headline.large` (36px, Semibold)

#### Title (Sub-sections & Card Titles)
- `DueDayTheme.typography.title.small` (20px, Semibold)
- `DueDayTheme.typography.title.medium` (22px, Semibold)
- `DueDayTheme.typography.title.large` (24px, Semibold)

#### Body (Content & Copy)
- `DueDayTheme.typography.body.large` (18px, Medium)
- `DueDayTheme.typography.body.medium` (16px, Regular)
- `DueDayTheme.typography.body.small` (14px, Regular)

#### Label (Interactive Widgets & Buttons)
- `DueDayTheme.typography.label.large` (16px, Medium)
- `DueDayTheme.typography.label.medium` (14px, Medium)
- `DueDayTheme.typography.label.small` (12px, Medium)

#### Caption (Metadata & Footnotes)
- `DueDayTheme.typography.caption.large` (12px, Regular)
- `DueDayTheme.typography.caption.small` (11px, Regular)

---

## 📏 Dimensions & Scaling

Managed through the static `DueDayTheme.dimensions` reference.

### 1. Border Radius
```dart
DueDayTheme.dimensions.radius.small           // 8.0
DueDayTheme.dimensions.radius.medium          // 12.0
DueDayTheme.dimensions.radius.large           // 16.0
DueDayTheme.dimensions.radius.extraLarge      // 20.0
DueDayTheme.dimensions.radius.circle          // 999.0 (perfect circle shape)
```

### 2. Core Sizing
```dart
DueDayTheme.dimensions.size.small             // 4.0
DueDayTheme.dimensions.size.smallMedium       // 8.0
DueDayTheme.dimensions.size.medium            // 12.0
DueDayTheme.dimensions.size.mediumLarge       // 16.0
DueDayTheme.dimensions.size.large             // 20.0
DueDayTheme.dimensions.size.largeExtraLarge   // 24.0
DueDayTheme.dimensions.size.extraLarge        // 28.0
DueDayTheme.dimensions.size.twoExtraLarge     // 36.0
DueDayTheme.dimensions.size.twoExtraLargeMedium // 40.0
DueDayTheme.dimensions.size.threeExtraLarge   // 64.0

// Icon Standards
DueDayTheme.dimensions.size.iconSmall         // 16.0
DueDayTheme.dimensions.size.iconMedium        // 24.0
DueDayTheme.dimensions.size.iconLarge         // 32.0

// Action Touch Standards
DueDayTheme.dimensions.size.buttonSmall       // 40.0
DueDayTheme.dimensions.size.buttonMedium      // 48.0
DueDayTheme.dimensions.size.buttonLarge       // 56.0
```

### 3. Spacing Tokens
Use spacing tokens to specify margins and paddings:
```dart
DueDayTheme.dimensions.spacing.extraSmall           // 2.0
DueDayTheme.dimensions.spacing.small                // 4.0
DueDayTheme.dimensions.spacing.smallMedium          // 8.0
DueDayTheme.dimensions.spacing.medium               // 12.0
DueDayTheme.dimensions.spacing.mediumLarge          // 16.0
DueDayTheme.dimensions.spacing.large                // 20.0
DueDayTheme.dimensions.spacing.largeExtraLarge      // 24.0
DueDayTheme.dimensions.spacing.extraLarge           // 28.0
DueDayTheme.dimensions.spacing.twoExtraLarge        // 36.0
DueDayTheme.dimensions.spacing.twoExtraLargeMedium  // 40.0
DueDayTheme.dimensions.spacing.threeExtraLarge      // 64.0
```

#### Pre-configured EdgeInset Padding Tokens
```dart
DueDayTheme.dimensions.spacing.paddingSmall           // EdgeInsets.all(4.0)
DueDayTheme.dimensions.spacing.paddingMedium          // EdgeInsets.all(12.0)
DueDayTheme.dimensions.spacing.paddingLarge           // EdgeInsets.all(20.0)
DueDayTheme.dimensions.spacing.paddingExtraLarge      // EdgeInsets.all(28.0)

DueDayTheme.dimensions.spacing.paddingHorizontalSmall // EdgeInsets.symmetric(horizontal: 4.0)
DueDayTheme.dimensions.spacing.paddingHorizontalLarge // EdgeInsets.symmetric(horizontal: 20.0)
DueDayTheme.dimensions.spacing.paddingVerticalSmall   // EdgeInsets.symmetric(vertical: 4.0)
DueDayTheme.dimensions.spacing.paddingVerticalLarge   // EdgeInsets.symmetric(vertical: 20.0)
```

### 4. Stroke (Border Widths)
```dart
DueDayTheme.dimensions.stroke.extraSmall      // 0.5
DueDayTheme.dimensions.stroke.small           // 1.0
DueDayTheme.dimensions.stroke.medium          // 1.5
DueDayTheme.dimensions.stroke.large           // 2.0
DueDayTheme.dimensions.stroke.extraLarge      // 2.5
DueDayTheme.dimensions.stroke.extraExtraLarge // 3.0
```

#### Helper Builders
```dart
// Generates custom BorderSide
borderSide: DueDayTheme.dimensions.stroke.asBorderSide(
  color: Colors.blue,
  strokeWidth: DueDayTheme.dimensions.stroke.large,
)

// Generates primary color BorderSide
borderSide: DueDayTheme.dimensions.stroke.asPrimarySide(
  primaryColor: DueDayTheme.colors.resource.primary,
)
```

---

## 📦 Shared Components Reference

### 1. Buttons (`components/buttons/`)

#### **AppTextButtonPrimary**
Primary high-contrast button featuring text, loading states, and icon configurations.
```dart
AppTextButtonPrimary(
  label: 'Submit Payment',
  onPressed: () {},
)

// With icon attachments
AppTextButtonPrimary(
  label: 'Add Category',
  prefixIcon: AppIcons.plus,
  onPressed: () {},
)

// Loading State (displays circular progress spinner instead of text)
AppTextButtonPrimary(
  label: 'Saving...',
  isLoading: true,
  onPressed: () {},
)
```

#### **AppTextButtonSecondary**
Outlined boundary styling for auxiliary configurations (e.g. Cancel actions).
```dart
AppTextButtonSecondary(
  label: 'Discard Draft',
  onPressed: () {},
)
```

#### **AppTextButtonTertiary**
Clean text-only links with zero borders/backgrounds (e.g. navigation links, settings options).
```dart
AppTextButtonTertiary(
  label: 'Forgot Password?',
  onPressed: () {},
)
```

### 2. Form Fields (`components/form_fields/`)

#### **AppTextField**
Input layout containing placeholder structures, validation errors, and adaptive styling.
```dart
AppTextField(
  controller: emailController,
  hintText: 'user@dueday.com',
  label: 'E-mail Address',
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email_outlined,
  validator: Validators.isValidEmail,
)
```

### 3. Structural Scaffolding (`components/structure/`)

#### **CustomScaffold**
Wraps pages, adapting canvas backdrops natively based on Light and Dark settings:
```dart
CustomScaffold(
  appBar: CustomAppBar(title: 'Settings'),
  body: MainSettingsWidget(),
)
```

---

## 🔀 Navigation Standards (GoRouter Integration)

Navigation operates via declarative GoRouter bindings. Import standard path constants and extension contexts.

```dart
// Transition commands
context.go('/dashboard');   // Push replace layout (Bottom Navigation abas)
context.push('/details');   // Push overlay route
context.pop();              // Pop route stack
```

---

## 🌍 Translation Integration (Localizations)

User strings are loaded dynamically from `AppLocalizations` delegates.
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final l10n = AppLocalizations.of(context)!;
print(l10n.authLoginTitle);
```

---

## 📝 Complete Layout Integration Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/design_system/components/form_fields/app_text_field.dart';
import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/core/utils/validators/validators.dart';

class LoginPageExample extends StatefulWidget {
  const LoginPageExample({super.key});

  @override
  State<LoginPageExample> createState() => _LoginPageExampleState();
}

class _LoginPageExampleState extends State<LoginPageExample> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radius = context.radius;

    return CustomScaffold(
      backgroundColor: colors.darkBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.twoExtraLargeMedium.width,  // Responsive Width scaling
            vertical: spacing.extraLarge.height,            // Responsive Height scaling
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.authLoginTitle,
                  textAlign: TextAlign.center,
                  style: typography.headline.medium.copyWith(
                    color: colors.onDarkBackground,
                  ),
                ),
                SizedBox(height: spacing.twoExtraLarge.height),

                AppTextField(
                  controller: _emailController,
                  hintText: l10n.authEmail,
                  label: l10n.authEmail,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.isValidEmail,
                ),
                SizedBox(height: spacing.mediumLarge.height),

                AppTextField(
                  controller: _passwordController,
                  hintText: l10n.authPassword,
                  label: l10n.authPassword,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.isValidPassword,
                ),
                SizedBox(height: spacing.large.height),

                AppTextButtonPrimary(
                  label: l10n.authLogInButton,
                  onPressed: _submit,
                ),
                SizedBox(height: spacing.medium.height),

                Center(
                  child: AppTextButtonTertiary(
                    label: l10n.authNoAccountPrompt,
                    onPressed: () => context.go('/signup'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## ⚡ Style Checklists

### ✅ DO:
- Use `DueDayTheme` properties exclusively for sizes, spaces, fonts, and colors.
- Use `context.go()` for bottom nav index abas, and `context.push()` / `context.pop()` for overlays.
- Utilize `AppTextField` and `AppTextButton*` implementations to guarantee brand compliance.
- Keep all texts inside the localized arb dictionaries.
- Append `.width` or `.height` to spacing metrics inside dynamic layouts.

### ❌ DO NOT:
- Hardcode raw numeric offsets, pixel sizes, or Color instances (`Colors.*`, `Color(0xFF...)`).
- Call legacy `Navigator.push(...)` routines.
- Construct duplicate custom form elements without consulting theme registries.
- Inject raw validation alerts or bypass localized translations.
