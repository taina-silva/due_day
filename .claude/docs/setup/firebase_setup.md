# Firebase Setup

Services used: **Authentication** and **Firestore**. No FCM.

## Prerequisites

```bash
npm install -g firebase-tools          # or: brew install firebase-cli
dart pub global activate flutterfire_cli
```

## Steps

1. **Project:** create it in the [Firebase Console](https://console.firebase.google.com/).
2. **Authentication:** enable the **Google** and **Email/Password** providers.
3. **Firestore:** create the database (any region; start in test mode, rules are deployed in step 5).
4. **Connect the app** from the repo root:
   ```bash
   firebase login
   flutterfire configure   # select the project; platforms: android + ios only
   ```
   Generates `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`.
5. **Rules:** `firebase deploy --only firestore:rules` (source: `firestore.rules`, see [firestore.md](../firestore.md)).
6. **Run:**
   ```bash
   fvm flutter pub get
   fvm flutter pub run build_runner build --delete-conflicting-outputs
   fvm flutter run
   ```
   Check that sign-up works and documents appear under `/users/{uid}/`.
