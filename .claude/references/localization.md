# Localization (localization.md)

This reference outlines language options, localized templates, translation key formats, and code generation commands for **DueDay**.

---

## 🌎 1. Supported Languages

DueDay supports two primary language profiles:
1.  **Português (pt-BR)** — Standard default translation catalog.
2.  **English (en-US)** — Secondary translation catalog.

Localization delegates and supported locales are loaded into the app wrapper inside `lib/main.dart` from the auto-generated `AppLocalizations` class:
```dart
locale: Locale(state.languageCode),
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,
```

---

## 📂 2. Catalog Directory Structures

All translations are defined using **ARB (Application Resource Bundle)** JSON format:
```
lib/core/l10n/
├── app_en.arb      # English translation catalog
└── app_pt.arb      # Portuguese translation catalog
```

---

## 🔑 3. Translation Key Formatting Rules

Keys inside the ARB files must follow camelCase layout using the `featureNomeChave` pattern:

| Feature | Key Example | Description |
| :--- | :--- | :--- |
| `splash` | `splashAppName`, `splashTagline` | App name and taglines. |
| `auth` | `authLoginTitle`, `authEmailHint` | Login/Signup parameters. |
| `accounts` | `accountsTitle`, `accountsEmptyState` | Financial account parameters.|
| `transactions` | `transactionsExpenseLabel`, `transactionsAmount` | Ledger entries strings. |
| `categories` | `categoriesAddNew`, `categoriesDeletePrompt`| Categories config. |
| `profile` | `profileSignOut`, `profileThemeMode` | Profile updates. |

---

## 🛠️ 4. Adding New Translations

1.  **Edit `app_en.arb`:**
    ```json
    "authEmailPlaceholder": "Enter your email"
    ```
2.  **Edit `app_pt.arb`:**
    ```json
    "authEmailPlaceholder": "Digite seu e-mail"
    ```
3.  **Generate Translations Adapter:**
    Run the generation command in your terminal:
    ```bash
    fvm flutter gen-l10n
    ```
4.  **Use inside Widgets:**
    ```dart
    final l10n = AppLocalizations.of(context);
    print(l10n.authEmailPlaceholder);
    ```
