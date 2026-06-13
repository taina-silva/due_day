# 🎯 DueDay — Personal Financial Control

**DueDay** is a modern and secure personal financial control and planning mobile application. It allows users to manage their bank accounts, register income, expense, and transfer transactions, create custom categories, and schedule payment due date reminders with integrated notifications.

Developed exclusively for **Android** and **iOS**, the project adopts the best mobile development practices, using **Clean Architecture**, **BLoC** for state management, and **Firebase** as the backend.

---

## 🚀 Key Features

- 🔐 **Secure Authentication**: Sign in via Email/Password and Google Sign-In, plus support for local biometric authentication and secure credentials storage.
- 📊 **Consolidated Dashboard**: Intuitive overview of the current balance, recent transactions, and financial summary.
- 💳 **Account Management**: Register and monitor financial accounts (cash wallet, banks, investments).
- 💸 **Transactions**: Detailed registration of income, expenses, and transfers between accounts.
- 🏷️ **Custom Categories**: Organize transactions by user-configured categories.
- 🔔 **Schedules and Notifications**: Payment due date reminders via local and push notifications.

---

## 🏗️ Architecture and Design Patterns

The project strictly follows **Clean Architecture** and **SOLID** principles, focusing on testability, decoupling, and maintainability.

### Project Layers

Business features (inside `lib/features/`) are divided into 3 layers with the dependency flow always pointing inwards (Presentation ➔ Domain 🠔 Data):

1. **Domain**: The innermost and pure layer (pure Dart, no framework dependencies).
   - **Entities**: Definitions of immutable business entities (using `Equatable`).
   - **UseCases**: Business rules isolated in callable classes via the `call(...)` method.
   - **Repositories**: Interfaces defining the data retrieval contract.

2. **Data**: Concrete implementation of contracts and integration with external services.
   - **Models**: Extensions of entities that add serialization/deserialization logic (using `freezed` and `json_serializable`).
   - **DataSources**: Raw I/O (communication with Firebase, external APIs, or local database).
   - **Repositories**: Implementation of repositories that manage data sources and convert exceptions into controlled failures.

3. **Presentation**: Visual layer and application state control.
   - **BLoC**: Reactive state orchestration and UI event processing (using `flutter_bloc`).
   - **Pages**: Screens that listen to the BLoC state to render the interface.
   - **Widgets**: Smaller and focused interface components.

### Cross-cutting Patterns

- **Functional Programming**: Structured error and return handling through the `fpdart` library using the `Either<Failure, T>` type (avoiding propagation of `try-catch` blocks to the UI).
- **Dependency Injection**: Managed centrally with `GetIt`, organized modularly by feature.
- **Declarative Routing**: Managed by `GoRouter` with tab state persistence (`StatefulShellRoute`) and global redirects based on the user's authentication state.
- **Centralized Design System**: Centralized under the `DueDayTheme` token, ensuring visual consistency of colors, fonts, and spacing. The entire interface uses responsive extensions (`.w`, `.h`, `.sp`, `.fs`) for fluid adaptation to different screen sizes.

---

## 📂 Folder Structure

The general source code organization is described below:

```
lib/
├── core/                         # Global and cross-cutting system resources
│   ├── design_system/            # Design System (tokens, components, themes)
│   ├── errors/                   # Exception and failure handling
│   ├── injection/                # Dependency Injection container settings (GetIt)
│   ├── l10n/                     # i18n support and translation files (pt/en)
│   ├── navigation/               # Centralized routing configuration (GoRouter)
│   ├── services/                 # Global services (Notifications, Secure Storage, Biometrics)
│   └── utils/                    # Utilities and project extensions
│
└── features/                     # Business features of the app
    ├── accounts/                 # Account Management
    ├── auth/                     # Authentication and Registration
    ├── categories/               # Category Management
    ├── dashboard/                # Main Control Dashboard
    ├── notifications/            # Notification Management
    ├── profile/                  # User Profile and Preferences
    ├── schedule/                 # Due Date Scheduling
    ├── splash/                   # SplashScreen and Initial Redirects
    └── transactions/             # Transaction Management (income/expenses)
```

---

## 🛠️ Technologies and Dependencies

- **Flutter SDK**: `3.41.6` (locked via `FVM`)
- **Dart SDK**: `3.11.4`
- **State Management**: `flutter_bloc` & `rxdart`
- **Navigation**: `go_router`
- **Dependency Injection**: `get_it`
- **Functional Programming**: `fpdart` & `equatable`
- **Local Security**: `local_auth` & `flutter_secure_storage`
- **Backend / Infra**: `firebase_core`, `firebase_auth`, `cloud_firestore`, and `firebase_messaging`
- **Code Generation**: `freezed`, `json_serializable`, and `build_runner`

---

## ⚙️ Setup and Run

### Prerequisites
Make sure you have [FVM (Flutter Version Management)](https://fvm.app/) installed on your system to ensure the correct Flutter version is used.

### Step-by-Step

1. **Get dependencies:**
   ```bash
   fvm flutter pub get
   ```

2. **Code Generation (Build Runner):**
   Immutable models (`freezed`) and translation files depend on automatic code generation.
   ```bash
   # Run a single build deleting conflicting files
   fvm flutter pub run build_runner build --delete-conflicting-outputs
   
   # Or run the watcher for continuous generation during development
   fvm flutter pub run build_runner watch --delete-conflicting-outputs
   ```

3. **Generate localization files (i18n):**
   ```bash
   fvm flutter gen-l10n
   ```

4. **Run the project:**
   ```bash
   fvm flutter run
   ```

---

## 🔒 Access Rules and Database (Firestore)

Data security is guaranteed at the database level (`firestore.rules`). All main subcollections are isolated by the unique identifier of the authenticated user:
- `/users/{userId}/accounts/...`
- `/users/{userId}/transactions/...`
- `/users/{userId}/categories/...`

No data can be accessed in a shared way or outside the active session user's `userId`.
