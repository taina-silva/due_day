# Standard Procedure: Debug Feature (debug_feature.md)

This guide describes how to investigate issues, debug state transitions, and analyze database changes in **DueDay**.

---

## 🛠️ Debugging Procedures

### 1. Inspecting BLoC State Transitions
DueDay implements BLoC observers to log state transitions in debug mode.
- Check the console logs for automated transition printouts:
  `Transition { currentState: AuthLoading, event: LoginEvent, nextState: AuthAuthenticated }`
- If transitions are missing, verify that the BLoC is dispatching events correctly and that states extend `Equatable` (otherwise, duplicate state emissions may be blocked).

### 2. Verifying Firestore Operations
When a database read or write fails:
1.  **Check security rules:** Verify that your query includes the authenticated user's `userId` parameter in the document path (`/users/{userId}/...`).
2.  **Verify document layout:** Open the Firebase Console and inspect the collection documents. Ensure field names and types (e.g. double vs integer, timestamp vs string) match the Freeze model definitions.
3.  **Check indices:** If a query fails with a Firestore exception, check the console output for a generated link to create a missing composite index.

### 3. Debugging Local Storage & Secure Storage
If biometric logins or cached configurations fail:
- Check the logs for `CacheException` or `SecureStorage` read/write blocks.
- On simulators/emulators, reset the device keychain or secure storage state to clear corrupted credentials:
  - **Android Emulator:** Clear App Data in the system settings.
  - **iOS Simulator:** Select "Device" ➔ "Erase All Content and Settings".
- Verify that permissions are declared correctly in native files:
  - `AndroidManifest.xml` (e.g. `USE_BIOMETRIC`)
  - `Info.plist` (e.g. `NSFaceIDUsageDescription`)
