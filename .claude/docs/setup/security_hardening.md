# Security Hardening

## API keys (Google Cloud Console)

- Android key restricted to package `com.dueday.due_day` + SHA-1 fingerprints; iOS key to bundle `com.dueday.dueDay`.
- Allowed APIs: Identity Toolkit, Cloud Firestore, Firebase Installations. (Cloud Messaging is still listed but unused and can be removed.)

## Secure storage

The biometric toggle (`is_biometrics_enabled`) is stored in `flutter_secure_storage`, not plain preferences, so it can't be edited on rooted/jailbroken devices. Future encryption keys (e.g. for Hive) must go there too.

## Native config

| Platform | What | Where |
| :--- | :--- | :--- |
| Android | `USE_BIOMETRIC` permission | `AndroidManifest.xml` |
| Android | `FLAG_SECURE` (blocks screenshots, recordings, recent-apps preview) | `MainActivity.kt` |
| iOS | `NSFaceIDUsageDescription` | `Info.plist` |
| iOS | Blur over the window in the app switcher (`sceneWillResignActive` / `sceneDidBecomeActive`) | `SceneDelegate.swift` |

## Biometric lock

- `SecurityService` (`lib/core/services/security_service.dart`) wraps `local_auth` + secure storage: `canAuthenticate`, `authenticate`, `isBiometricsEnabled`, `setBiometricsEnabled`.
- `main_wrapper_page.dart`: when biometrics are on and the app resumes (or cold-starts), `BiometricLockOverlay` blocks the UI until authentication succeeds.

## Manual checks

- Android: screenshot is blocked; app switcher shows a black window.
- iOS: app switcher preview is blurred.
- Biometrics: enabling asks for auth; returning from background and cold start both show the lock.
