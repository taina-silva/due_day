# Design System

All UI styling goes through `lib/core/design_system/`. Full screen template: [create-screen](../skills/create-screen/SKILL.md).

## Rules

- Never hardcode colors (`Colors.*`, `Color(0xFF…)`), sizes, or `'assets/…'` paths.
- Apply `.w` / `.h` / `.sp` / `.fs` (`NumExtension`) to every numeric layout value.
- Touch targets ≥ **44x44**; text contrast **WCAG AA**.
- Use shared components (`AppTextField`, `AppTextButton*`, `CustomScaffold`) instead of building new ones.
- Feedback messages only via `AppMessenger` — never `ScaffoldMessenger`/`SnackBar`.

## Access

Inside `build`, use the `BuildContext` extension (`due_day_theme_extension.dart`):

| Getter | Type |
| :--- | :--- |
| `context.colors` | `AppColorsSys` |
| `context.typography` | `AppTypography` |
| `context.spacing` / `radius` / `sizes` / `stroke` | dimension tokens |
| `context.isDarkMode`, `surfaceColor`, `onSurfaceColor`, `onSurfaceVariantColor`, `primaryColor`, `errorColor`, `scaffoldBackgroundColor` | theme-adaptive helpers |

Without a context (e.g. `ThemeData` setup), use `DueDayTheme.colors` / `.dimensions` / `.typography`.

## Colors

- **Brand** `colors.resource.*`: `primary` (#166bd5), `secondary`, `neutral`, `primaryWith30Opacity`, `primaryWith15Opacity`.
- **Feedback** `colors.system.*`: `success`, `error`, `warning`, `info`.
- **Surfaces**: `lightBackground`, `darkBackground`, `lightSurface`, `darkSurface`, `onLightBackground`, `onDarkBackground`.

## Typography

Font **Sofia Sans** (400 / 500 / 600). Sizes scale automatically.

| Scale | small | medium | large |
| :--- | :--- | :--- | :--- |
| `headline` | 24 | 32 | 36 |
| `title` | 20 | 22 | 24 |
| `body` | 14 | 16 | 18 |
| `label` | 12 | 14 | 16 |
| `caption` | 11 | — | 12 |

## Dimensions

- **radius**: `small` 8 · `medium` 12 · `large` 16 · `extraLarge` 20 · `circle`
- **sizes**: `small` 4 → `largeExtraLarge` 24; `icon{Small,Medium,Large}` 16/24/32; `button{Small,Medium,Large}` 40/48/56
- **spacing**: `extraSmall` 2 · `small` 4 · `smallMedium` 8 · `medium` 12 · `mediumLarge` 16 · `large` 20 · `extraLarge` 28 · `twoExtraLarge` 36 · `twoExtraLargeMedium` 40 · `threeExtraLarge` 64; plus `padding{Small,Medium,Large,ExtraLarge}` and `padding{Horizontal,Vertical}{Small,Large}`
- **stroke**: 0.5 → 3.0; helpers `asBorderSide(...)`, `asPrimarySide(...)`

## Components

```dart
AppTextButtonPrimary(label: l10n.save, onPressed: _submit);   // also Secondary (outlined), Tertiary (text)
AppTextField(controller: c, label: l10n.email, validator: Validators.isValidEmail);
CustomScaffold(appBar: CustomAppBar(titleText: l10n.title), body: ...);
AppImageWidget(image: AppImages.logoForeground, semanticLabel: l10n.logoLabel);
```

- **Images:** every bundled asset is an `AppImages` enum member; `AppImageWidget` requires a localized `semanticLabel`. Custom SVGs will follow the same pattern (`AppIcons`); Material `Icons.*` stay the default.

### AppMessenger

```dart
AppMessenger.showSuccess(context, l10n.saved);
AppMessenger.showError(context, failure.toLocalizedString(context));
AppMessenger.showInfo(context, l10n.info);
```

It renders on the **root `Overlay`**, so toasts appear above bottom sheets and dialogs with no local `Scaffold` needed. In tests, find it by `Key('app_messenger_toast')`, not by `SnackBar`.
