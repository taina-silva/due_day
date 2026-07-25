# Firebase Configuration & Setup Guide (firebase_setup.md)

Step-by-step instructions to connect the **DueDay** Flutter application with Firebase back-end services (Authentication, Firestore Database, and Cloud Messaging).

---

## 📋 Prerequisites

Ensure you have the following installed and configured on your development machine:
1. A active Google Account to access the Firebase Console.
2. **Firebase CLI:** Install globally via Node Package Manager or Homebrew:
   ```bash
   npm install -g firebase-tools
   # or via homebrew
   brew install firebase-cli
   ```
3. **FlutterFire CLI:** Used for automated platform setups. Run:
   ```bash
   dart pub global activate flutterfire_cli
   ```

---

## 🛠️ Step-by-Step Integration

### 1. Create a Firebase Project
1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** (or **Create Project**).
3. Set the project name as **DueDay** (or a unique identifier like `dueday-app`).
4. Enable or disable Google Analytics (optional for local development).
5. Click **Create Project** and wait for provisioning.

### 2. Enable Required Firebase Services

#### A. Authentication
1. Navigate to **Build** > **Authentication** in the left sidebar, then click **Get Started**.
2. Under the **Sign-in method** tab, select and enable the **Google** provider.
3. Configure the project support email and click **Save**.
4. Repeat the process for the **Email/Password** provider (enable it and click **Save**).

#### B. Cloud Firestore
1. Navigate to **Build** > **Firestore Database**, then click **Create Database**.
2. Select **Start in Test mode** (we will override this with production security rules in step 4).
3. Set database location to `us-central1` (or your preferred region) and click **Enable**.

#### C. Cloud Messaging (FCM)
Not currently used — DueDay's notifications are 100% on-device local reminders (see [notifications.md](../docs/notifications.md)). Skip this service unless push notifications are added to the roadmap.

---

### 3. Initialize FlutterFire Connections
Open your terminal at the root of the `due_day` directory:

1. **Log in to Firebase:**
   ```bash
   firebase login
   ```
2. **Run automatic configuration:**
   ```bash
   flutterfire configure
   ```
3. **Configuration wizard choices:**
   - Select your newly created Firebase project from the list.
   - Choose the target platforms: **android** and **ios** (uncheck other platforms).
   - Confirm Bundle ID registrations.

This utility automatically generates:
- `lib/firebase_options.dart` — initialization settings for Dart.
- `android/app/google-services.json` — Google Services configuration for Android.
- `ios/Runner/GoogleService-Info.plist` — Google Service PLIST settings for iOS.

---

### 4. Apply Firestore Security Rules
To restrict cross-user database access, synchronize your remote rules with the local configuration. The canonical rules live in the repo's `firestore.rules` file (see [firestore.md §2](../docs/firestore.md#-2-security-rules-firestorerules) for what they enforce) — deploy them with:
```bash
firebase deploy --only firestore:rules
```

---

### 5. Install Dependencies & Build
Verify that the native bindings compile and run successfully:

1. **Fetch packages:**
   ```bash
   fvm flutter pub get
   ```
2. **Trigger model generation:**
   ```bash
   fvm flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. **Launch the app on your emulator or device:**
   ```bash
   fvm flutter run
   ```
4. Verify that users can register, sign in (Email or Google), and database documents populate under `/users/{uid}/` within the Firebase console.
