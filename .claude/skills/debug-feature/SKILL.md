---
name: debug-feature
description: Use when investigating a bug in DueDay — BLoC state transitions not firing, Firestore reads/writes failing, or biometric/secure-storage issues. Covers BLoC observer logs, security-rule/index checks, and native permission checks.
---

# Debug Feature

Fixes follow the lightweight change flow: reproduction + expected behavior in `proposal.md`, plus a regression test ([specs/README.md](../../../specs/README.md)).

## BLoC not updating

- `AppBlocObserver` logs only bloc type names and errors. Add temporary logs in handlers to trace transitions, and remove them afterwards.
- Same state emitted twice? `Equatable` drops it. Action blocs must emit `XActionInProgress` first.
- Screen blank after a mutation? Check that it reads `XLoadBloc`, not the Action Bloc.

## Firestore

1. Path starts with `/users/{userId}`? Otherwise rules reject it.
2. Document fields and types match the model ([firestore.md](../../docs/firestore.md))?
3. Query error with a console link → missing composite index.
4. Check repository logs (`tag` = feature).

## Biometrics / secure storage

- Look for `CacheException` or `SecurityService` warnings.
- Reset state: Android → clear app data; iOS Simulator → Erase All Content and Settings.
- Check `USE_BIOMETRIC` (`AndroidManifest.xml`) and `NSFaceIDUsageDescription` (`Info.plist`).
