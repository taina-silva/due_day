# Design System (design_system.md)

This document describes the **DueDay** Design System, which centralizes UI styles, tokens, and reusable components to maintain visual consistency, accessibility, and fluid responsiveness.

---

## 🎯 1. Theme Gateway (`DueDayTheme` & `BuildContext` Extension)

The design system is defined under `DueDayTheme`, but the **recommended** way to access it inside build methods is via the **`BuildContext` extension** (defined in [due_day_theme_extension.dart](file:///Users/tainass/Personal/Projetos%20Pessoais/due_day/lib/core/design_system/theme/due_day_theme_extension.dart)):

### BuildContext Shortcut Getters
- **Colors:** `context.colors` (instead of `DueDayTheme.colors`)
- **Typography:** `context.typography` (instead of `DueDayTheme.typography`)
- **Dimensions:** `context.dimensions` (instead of `DueDayTheme.dimensions`)
- **Spacing:** `context.spacing` (instead of `DueDayTheme.dimensions.spacing`)
- **Radius:** `context.radius` (instead of `DueDayTheme.dimensions.radius`)
- **Sizes:** `context.sizes` (instead of `DueDayTheme.dimensions.size`)
- **Stroke:** `context.stroke` (instead of `DueDayTheme.dimensions.stroke`)

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
│   │   ├── messenger.dart             # Unified SnackBars and dialog alerts
│   │   └── index.dart
│   ├── structure/
│   │   ├── custom_scaffold.dart       # Theme-adaptive scaffolds
│   │   ├── custom_app_bar.dart        # Reusable Top AppBars
│   │   ├── custom_app_bottom_nav_bar.dart
│   │   └── index.dart
│   └── design_system.dart             # Central exports
├── icons/
│   ├── app_icon.dart                  # SVG icon container
│   ├── app_icons.dart                 # Enum listing available SVGs
│   └── index.dart
└── images/
    ├── app_image_widget.dart
    ├── app_images.dart
    └── index.dart
```

---

## 🎨 3. Color Tokens (`DueDayTheme.colors`)

Do not use standard Flutter colors (e.g. `Colors.blue`) or raw hex codes. Always query the semantic properties:

### 3.1. Resource Colors (Brand Elements)

- `colors.resource.primary` — Signature blue (#166bd5)
- `colors.resource.secondary` — Branding helper color
- `colors.resource.neutral` — Muted gray
- `colors.resource.primaryWith30Opacity` — 30% alpha blue
- `colors.resource.primaryWith15Opacity` — 15% alpha blue

### 3.2. System Colors (Feedback States)

- `colors.system.success` — Action success green (#13C999)
- `colors.system.error` — Execution failure red (#FF6363)
- `colors.system.warning` — Alert warning yellow
- `colors.system.info` — Informational status blue

### 3.3. Base Scaffolding & Surface Colors

- `colors.lightBackground` — Scaffold canvas for Light Theme (white)
- `colors.darkBackground` — Scaffold canvas for Dark Theme (dark gray)
- `colors.lightSurface` — Container/Card surface for Light Theme
- `colors.darkSurface` — Container/Card surface for Dark Theme
- `colors.onLightBackground` — Dark foreground text on light backgrounds
- `colors.onDarkBackground` — Light foreground text on dark backgrounds

---

## 🔤 4. Typography (`DueDayTheme.typography`)

DueDay utilizes the **Sofia Sans** Google Font, configured in three weights:

- **Regular (400):** Generic copy/text.
- **Medium (500):** Indicators and highlighted texts.
- **Semibold (600):** Titles and labels.

### Typography Scales

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

_Note: All font sizes scale automatically using responsive extensions._

---

## 📏 5. Dimensions (`DueDayTheme.dimensions`)

### 5.1. Border Radius

- `radius.small` (8.0), `radius.medium` (12.0), `radius.large` (16.0), `radius.extraLarge` (20.0), `radius.circle` (999.0)

### 5.2. Core Component Sizes

- `size.small` (4.0), `size.smallMedium` (8.0), `size.medium` (12.0), `size.mediumLarge` (16.0), `size.large` (20.0)
- `size.iconSmall` (16.0), `size.iconMedium` (24.0), `size.iconLarge` (32.0)
- `size.buttonSmall` (40.0), `size.buttonMedium` (48.0), `size.buttonLarge` (56.0)

### 5.3. Spacing Tokens (Marginal layouts)

- `spacing.extraSmall` (2.0), `spacing.small` (4.0), `spacing.smallMedium` (8.0), `spacing.medium` (12.0), `spacing.mediumLarge` (16.0), `spacing.large` (20.0), `spacing.extraLarge` (28.0), `spacing.twoExtraLarge` (36.0), `spacing.twoExtraLargeMedium` (40.0), `spacing.threeExtraLarge` (64.0)

---

## 📦 6. Shared Components

### 6.1. Buttons

- **`AppTextButtonPrimary`:** High-contrast background with loading spinners and prefix/suffix icon support.
- **`AppTextButtonSecondary`:** Outlined shape for auxiliary activities (e.g. Cancel).
- **`AppTextButtonTertiary`:** Transparent text-only buttons (e.g. Forgot Password).

### 6.2. Forms

- **`AppTextField`:** Input field wrapping decoration, theme adapters, and validator errors.
- **`AppDropdownField`:** Consistent dropdown styling.

### 6.3. Scaffolds

- **`CustomScaffold`:** Seamlessly adapts base backgrounds to match Light and Dark themes.
- **`CustomAppBar`:** A centered-title header providing default `GoRouter` popping features.

---

## ⚡ 7. Design Standards & Checklist

1.  **Accessibility:** Elements require a minimum touch surface of **44x44px** and must comply with **WCAG AA** color contrast rules.
2.  **Orientation Support:** Layouts must support both **Portrait** and **Landscape** orientations, maintaining fluid and adaptive interfaces.
3.  **Responsiveness:** Always apply `.w`, `.h`, `.sp`, or `.fs` from `NumExtension` to sizing, spacing, margins, and font parameters.
4.  **Strict Styling Rules:** Do not write custom layout overrides or raw colors. Always delegate dimensions, font styles, and colors to `DueDayTheme`.

