# Project Structure Map (project_structure.md)

This reference document outlines the complete directory layout of the **DueDay** application.

---

## 📂 1. Directory Tree

```
due_day/
├── .fvm/                         # Flutter version config
├── android/                      # Native Android configuration
├── ios/                          # Native iOS configuration
├── assets/                       # Asset bundles
│   ├── fonts/                    # Sofia Sans typeface files
│   ├── icons/                    # Vector icons (SVG)
│   └── images/                   # Pixel art & raster elements (PNG/JPG)
├── docs/                         # AI Context Conceptual guides
├── references/                   # Structured reference files
├── skills/                       # Procedure recipe files
├── agents/                       # Specialized AI role descriptions
├── test/                         # Suite of automated tests
└── lib/                          # Core codebase
    ├── main.dart                 # App initialization entry point
    ├── firebase_options.dart     # Auto-generated Firebase settings
    ├── core/                     # Reusable global configurations
    └── features/                 # Business domain features
```

---

## 🏗️ 2. Core Library Modules (`lib/core/`)

The `lib/core/` directory contains system-wide services, utilities, and styling tokens:

- **`design_system/`**: Custom widgets, layout themes, icons, and animations.
  - `components/`: Custom inputs (`AppTextField`), buttons (`AppTextButtonPrimary`), dialog banners.
  - `icons/` & `images/`: SVG/PNG assets wrappers.
  - `theme/`: Global style settings (`DueDayTheme`, `AppColorsSys`, typography, spacings).
- **`errors/`**: Defines controlled exceptions (`ServerException`, `CacheException`) and failure containers (`ServerFailure`, `CacheFailure`).
- **`injection/`**: Central Service Locator initialization. Modular setup configuration for each business feature is called from `injection_container.dart`.
- **`l10n/`**: Localization delegation hooks (`AppLocalizations`). Contains template `.arb` translation catalog files.
- **`navigation/`**: Central GoRouter routes setup (`app_router.dart`), biometric security overlay, and redirection stream list.
- **`services/`**: Low-level platform adapters like `NotificationService` (local alerts) and `SecurityService` (local biometrics + credentials store).
- **`settings/`**: System settings bloc to control theme modes (Light/Dark) and active localization locale parameters.
- **`utils/`**: Shared helper extensions such as `NumExtension` for UI layout scaling.

---

## 💳 3. Feature Modules (`lib/features/`)

Business features are isolated into modular directories under `lib/features/`. Each folder encapsulates its own Clean Architecture layers:

- **`auth/`**: User registration, authentication, login/signup layout pages, and Google OAuth flows.
- **`accounts/`**: Financial account creation, balance configuration, and credit card statement setups.
- **`transactions/`**: Income, expense, and transfer records. Handles query filtering parameters.
- **`categories/`**: User custom category labels, selection pages, and color settings.
- **`dashboard/`**: Orchestrates balance totals and next-to-expire reminders. Consumes other features' UseCases.
- **`schedule/`**: Chronological timelines displaying transactions grouped by payment due dates.
- **`notifications/`**: App settings for push notifications and Firestore FCM registration tokens.
- **`profile/`**: User settings summary, themes, language updates, and session logout controls.
- **`splash/`**: Root loading screen displaying logo while authentication initializes.
