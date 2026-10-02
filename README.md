# DueDay

Personal spending tracker for **Android** and **iOS**: see how much you spent this month, on what, and compared with last month. Bank statements (Nubank) are the main input, and on-device reminders cover upcoming bills.

Product and roadmap: [specs/product.md](specs/product.md).

## Stack

Flutter `3.41.6` (FVM) · BLoC · GoRouter · GetIt · fpdart · freezed · Firebase Auth + Firestore · Hive · local notifications · biometrics + secure storage.

Clean Architecture (`Presentation → Domain ← Data`). Details in [.claude/docs/architecture.md](.claude/docs/architecture.md).

## Run

Requires [FVM](https://fvm.app/). Firebase setup: [.claude/docs/setup/firebase_setup.md](.claude/docs/setup/firebase_setup.md).

```bash
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter gen-l10n
fvm flutter run
```

## Tests

```bash
fvm flutter test
```

## Data security

All data lives under `/users/{userId}/` in Firestore, and `firestore.rules` only allows the authenticated owner.
