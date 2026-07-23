# Design System (design_system.md)

This document describes the **DueDay** Design System, which centralizes UI styles, tokens, and reusable components to maintain visual consistency, accessibility, and fluid responsiveness.

---

## 🎯 1. Theme Gateway (`DueDayTheme` & `BuildContext` Extension)

The design system is defined under `DueDayTheme`, but the **recommended** way to access it inside build methods is via the **`BuildContext` extension** (defined in [due_day_theme_extension.dart](file:///Users/tainass/Personal/Projetos%20Pessoais/due_day/lib/core/design_system/theme/due_day_theme_extension.dart)):

### BuildContext Shortcut Getters (Recommended)
- **Colors:** `context.colors` (returns `AppColorsSys`)
- **Typography:** `context.typography` (returns `AppTypography`)
- **Dimensions:** `context.dimensions` (returns `AppDimensions`)
- **Spacing:** `context.spacing` (returns `SpacingStyles`)
- **Radius:** `context.radius` (returns `RadiusStyles`)
- **Sizes:** `context.sizes` (returns `SizesStyles`)
- **Stroke:** `context.stroke` (returns `StrokeStyles`)

### Theme-Adaptive Colors (Context Helpers)
- `context.isDarkMode` — Returns `true` if device is in dark mode.
- `context.scaffoldBackgroundColor` — Scaffold color for active theme.
- `context.surfaceColor` — Surface color for active theme.
- `context.onSurfaceColor` — On-surface foreground color.
- `context.onSurfaceVariantColor` — On-surface secondary foreground color.
- `context.primaryColor` — Theme primary color.
- `context.errorColor` — Theme error color.

*Note: For locations where `BuildContext` is not available (like static theme creation), the static interface `DueDayTheme.colors` / `DueDayTheme.dimensions` / `DueDayTheme.typography` is still used.*

---

## 📂 2. Directory Structure

```
lib/core/design_system/
├── components/
│   ├── avatar/
│   ├── buttons/
│   │   ├── app_text_button.dart       # Primary, Secondary, and Tertiary buttons
│   │   ├── app_icon_button.dart       # Custom icon-action buttons
│   │   └── index.dart
│   ├── cards/
│   │   ├── app_card.dart
│   │   └── index.dart
│   ├── form_fields/
│   │   ├── app_text_field.dart        # Central text fields with validations
│   │   ├── app_dropdown_field.dart
│   │   └── index.dart
│   ├── loading/
│   │   ├── circular_loading_on_primary.dart
│   │   ├── circular_loading_primary.dart
│   │   └── index.dart
│   ├── messenger/
│   │   └── app_messenger.dart         # AppMessenger + AppMessengerContent — unified success/error/info SnackBars
│   ├── structure/
│   │   ├── custom_scaffold.dart       # Theme-adaptive scaffolds
│   │   ├── custom_app_bar.dart        # Reusable Top AppBars
│   │   ├── custom_app_bottom_nav_bar.dart
│   │   └── index.dart
│   └── design_system.dart             # Central exports
├── theme/
│   ├── app_colors/
│   │   ├── app_colors.dart            # Theme base setup
│   │   ├── resource_colors.dart       # Brand specific colors
│   │   └── system_colors.dart         # Status feedback colors
│   ├── app_dimensions/
│   │   ├── app_dimensions.dart        # Sizing system base setup
│   │   ├── radius_styles.dart         # Rounded corners tokens
│   │   ├── sizes_styles.dart          # Component sizes tokens
│   │   ├── spacing_styles.dart        # Layout margins and paddings
│   │   └── stroke_styles.dart         # Border stroke tokens
│   ├── app_typography/
│   │   ├── app_typography.dart        # Typography system base setup
│   │   └── typography_styles.dart     # Typography styles scales
│   ├── app_theme.dart                 # Configures ThemeData for Light/Dark
│   ├── due_day_theme.dart             # Global static access
│   ├── due_day_theme_extension.dart   # BuildContext extension shortcuts
│   └── theme.dart                     # Flat exports manifest
├── icons/                              # Reserved: added once a custom SVG icon exists
│   ├── app_icon.dart                  # SVG icon container
│   └── app_icons.dart                 # Enum listing available SVGs
└── images/
    ├── app_image_widget.dart          # Image.asset wrapper requiring a semanticLabel
    └── app_images.dart                # Enum listing available bundled images
```

---

## 🎨 3. Color Tokens

Do not use standard Flutter colors (e.g. `Colors.blue`) or raw hex codes. Always query the semantic properties:

### 3.1. Resource Colors (Brand Palette)
- `context.colors.resource.primary` — Signature blue (#166bd5)
- `context.colors.resource.secondary` — Branding helper color (#9E9E9E)
- `context.colors.resource.neutral` — Muted gray (#E0E0E0)
- `context.colors.resource.primaryWith30Opacity` — 30% alpha blue
- `context.colors.resource.primaryWith15Opacity` — 15% alpha blue

### 3.2. System Colors (Feedback States)
- `context.colors.system.success` — Action success green (#13C999)
- `context.colors.system.error` — Execution failure red (#FF6363)
- `context.colors.system.warning` — Alert warning yellow (#FFB74D)
- `context.colors.system.info` — Informational status blue (#456EFE)

### 3.3. Base Scaffolding & Surface Colors (Static Theme Reference)
- `context.colors.lightBackground` — Scaffold canvas for Light Theme (white)
- `context.colors.darkBackground` — Scaffold canvas for Dark Theme (dark gray)
- `context.colors.lightSurface` — Container/Card surface for Light Theme
- `context.colors.darkSurface` — Container/Card surface for Dark Theme
- `context.colors.onLightBackground` — Dark foreground text on light backgrounds
- `context.colors.onDarkBackground` — Light foreground text on dark backgrounds

---

## 🔤 4. Typography

DueDay utilizes the **Sofia Sans** Google Font, configured in three weights:
- **Regular (400):** Generic copy/text.
- **Medium (500):** Indicators and highlighted texts.
- **Semibold (600):** Titles and labels.

### Typography Scales (`context.typography.*`)
- **Headline (Large title structures):**
  - `typography.headline.small` (24px, Semibold)
  - `typography.headline.medium` (32px, Semibold)
  - `typography.headline.large` (36px, Semibold)
- **Title (Section boundaries):**
  - `typography.title.small` (20px, Semibold)
  - `typography.title.medium` (22px, Semibold)
  - `typography.title.large` (24px, Semibold)
- **Body (Primary contents):**
  - `typography.body.large` (18px, Medium)
  - `typography.body.medium` (16px, Regular)
  - `typography.body.small` (14px, Regular)
- **Label (Control widgets):**
  - `typography.label.large` (16px, Medium)
  - `typography.label.medium` (14px, Medium)
  - `typography.label.small` (12px, Medium)
- **Caption (Footnotes):**
  - `typography.caption.large` (12px, Regular)
  - `typography.caption.small` (11px, Regular)

*Note: All font sizes scale automatically using responsive extensions (e.g. `36.fontSize` under the hood).*

---

## 📏 5. Dimensions & Scaling

### 5.1. Border Radius (`context.radius.*`)
- `radius.small` (8.0), `radius.medium` (12.0), `radius.large` (16.0), `radius.extraLarge` (20.0), `radius.circle` (999.0)

### 5.2. Core Component Sizes (`context.sizes.*`)
- `sizes.small` (4.0), `sizes.smallMedium` (8.0), `sizes.medium` (12.0), `sizes.mediumLarge` (16.0), `sizes.large` (20.0), `sizes.largeExtraLarge` (24.0)
- `sizes.iconSmall` (16.0), `sizes.iconMedium` (24.0), `sizes.iconLarge` (32.0)
- `sizes.buttonSmall` (40.0), `sizes.buttonMedium` (48.0), `sizes.buttonLarge` (56.0)

### 5.3. Spacing Tokens (Marginal layouts - `context.spacing.*`)
- `spacing.extraSmall` (2.0), `spacing.small` (4.0), `spacing.smallMedium` (8.0), `spacing.medium` (12.0), `spacing.mediumLarge` (16.0), `spacing.large` (20.0), `spacing.extraLarge` (28.0), `spacing.twoExtraLarge` (36.0), `spacing.twoExtraLargeMedium` (40.0), `spacing.threeExtraLarge` (64.0)

#### Pre-configured EdgeInset Padding Tokens
- `spacing.paddingSmall` — `EdgeInsets.all(4.0)`
- `spacing.paddingMedium` — `EdgeInsets.all(12.0)`
- `spacing.paddingLarge` — `EdgeInsets.all(20.0)`
- `spacing.paddingExtraLarge` — `EdgeInsets.all(28.0)`
- `spacing.paddingHorizontalSmall` — `EdgeInsets.symmetric(horizontal: 4.0)`
- `spacing.paddingHorizontalLarge` — `EdgeInsets.symmetric(horizontal: 20.0)`
- `spacing.paddingVerticalSmall` — `EdgeInsets.symmetric(vertical: 4.0)`
- `spacing.paddingVerticalLarge` — `EdgeInsets.symmetric(vertical: 20.0)`

### 5.4. Stroke (Border Widths - `context.stroke.*`)
- `stroke.extraSmall` (0.5), `stroke.small` (1.0), `stroke.medium` (1.5), `stroke.large` (2.0), `stroke.extraLarge` (2.5), `stroke.extraExtraLarge` (3.0)

#### Helper Builders
```dart
// Generates custom BorderSide
borderSide: context.stroke.asBorderSide(
  color: Colors.blue,
  strokeWidth: context.stroke.large,
)

// Generates primary color BorderSide
borderSide: context.stroke.asPrimarySide(
  primaryColor: context.colors.resource.primary,
)
```

---

## 📦 6. Shared Components

### 6.1. Buttons (`components/buttons/`)

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
Clean text-only links with zero borders/backgrounds (e.g. navigation links).
```dart
AppTextButtonTertiary(
  label: 'Forgot Password?',
  onPressed: () {},
)
```

### 6.2. Forms (`components/form_fields/`)

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

### 6.3. Scaffolds (`components/structure/`)

#### **CustomScaffold**
Wraps pages, adapting canvas backdrops natively based on Light and Dark settings:
```dart
CustomScaffold(
  appBar: CustomAppBar(titleText: 'Settings'),
  body: MainSettingsWidget(),
)
```

### 6.4. Images (`images/`)

#### **AppImages & AppImageWidget**
Bundled image assets are never referenced as raw `'assets/...'` strings. Each image is a member of the `AppImages` enum (carrying its bundle path) and is rendered through `AppImageWidget`, which requires a localized `semanticLabel` for screen readers:
```dart
AppImageWidget(
  image: AppImages.logoForeground,
  semanticLabel: l10n.splashLogoSemanticLabel,
  width: 104.scale,
  height: 104.scale,
)
```
Only assets actually consumed by the app belong in `AppImages` — store-listing artifacts (e.g. `appstore.png`, `playstore.png`) are not enum members.

Custom SVG icons will follow the identical pattern under `icons/` (`AppIcons` enum + `AppIcon` widget) once the first custom icon is introduced; Material's built-in `Icons.*` remain the default for anything that isn't a custom asset.

### 6.5. Messenger / SnackBars (`components/messenger/`)

#### **AppMessenger**
Single entry point for all success, error, and info feedback. It replaces ad-hoc `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))` calls with a consistently styled, color-coded `SnackBar` (green/red/blue via `context.colors.system.*`) that always ships with a dismiss (X) action on the trailing edge (via Flutter's native `SnackBar.showCloseIcon`). **Any feature that needs to show a transient success/error/info message must use `AppMessenger` — never build a raw `SnackBar` inline.**
```dart
AppMessenger.showSuccess(context, l10n.transactionsSavedSuccess);
AppMessenger.showError(context, failure.toLocalizedString(context));
AppMessenger.showInfo(context, l10n.someInfoMessage);
```
For custom durations or direct access to the `AppMessengerType` enum, call `AppMessenger.show(context, message: ..., type: AppMessengerType.success, duration: ...)`. The row content (`AppMessengerContent`) is exposed as its own `StatelessWidget` for isolated testing/previewing.

---

## 🔀 7. Navigation & Localization Integration

### 7.1. Declarative Navigation (GoRouter)
Navigation operates via declarative GoRouter bindings. Import standard path constants and extension contexts.
```dart
context.go('/dashboard');   // Push replace layout (Bottom Navigation tabs)
context.push('/details');   // Push overlay route
context.pop();              // Pop route stack
```

### 7.2. Translation Integration (Localizations)
User strings are loaded dynamically from `AppLocalizations` delegates.
```dart
import 'package:due_day/core/l10n/app_localizations.dart';

final l10n = AppLocalizations.of(context);
print(l10n.authLoginTitle);
```

---

## 📝 8. Complete Layout Integration Template

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/design_system/components/form_fields/app_text_field.dart';
import 'package:due_day/core/design_system/components/messenger/app_messenger.dart';
import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
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
    } else {
      AppMessenger.showError(context, AppLocalizations.of(context).validatorRequired);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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

## ⚡ 9. Design Standards & Checklist

### ✅ DO:
- Use `BuildContext` theme extension properties exclusively for sizes, spaces, fonts, and colors inside build methods.
- Use `context.go()` for bottom nav index tabs, and `context.push()` / `context.pop()` for overlays.
- Utilize `AppTextField` and `AppTextButton*` implementations to guarantee brand compliance.
- Use `AppMessenger.showSuccess/showError/showInfo` for any transient feedback message instead of a raw `SnackBar`.
- Keep all texts inside the localized arb dictionaries.
- Append `.width` (or `.w`) and `.height` (or `.h`) to spacing metrics inside dynamic layouts.
- Ensure interactive elements have a minimum touch surface of **44x44px** and comply with **WCAG AA** color contrast rules.
- Support both **Portrait** and **Landscape** orientations, maintaining fluid and adaptive interfaces.

### ❌ DO NOT:
- Hardcode raw numeric offsets, pixel sizes, or Color instances (`Colors.*`, `Color(0xFF...)`).
- Call legacy `Navigator.push(...)` routines.
- Construct duplicate custom form elements without consulting theme registries.
- Inject raw validation alerts or bypass localized translations.
- Call `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))` directly — always go through `AppMessenger`.
