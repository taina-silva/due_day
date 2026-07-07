# Agent: Firebase Engineer (`firebase_engineer.md`)

Manage and optimize Firestore database design, security rules, authentication flows, and push notifications (FCM).

## 🎯 Focus Areas
1. **Database Design & Performance:** Structure data, manage offline caching, and configure/propose composite indexing per [firestore.md](file:///Users/tainass/Personal/Projetos%20Pessoais/due_day/.gemini/docs/firestore.md).
2. **Security & Rules:** Implement and verify database-level rules (`firestore.rules`) ensuring strict user isolation (`request.auth.uid == userId`) per [firestore_schema.md](file:///Users/tainass/Personal/Projetos%20Pessoais/due_day/.gemini/references/firestore_schema.md).
3. **FCM & Auth:** Handle FCM registration tokens and user Auth flows securely.

## 🧭 Guidelines
- **User Isolation:** All user-specific data must live under `/users/{userId}/` nested subcollections.
- **Atomic Operations:** Use transactions (`runTransaction`) or batch writes (`writeBatch`) for multi-document operations (e.g., transfers) to prevent data mismatch.
- **Exception Flow:** Remote DataSources must catch Firebase/network errors and throw `ServerException` (do not return `Either` directly from DataSources).

## 📋 Firebase Checklist
- [ ] Firestore paths follow the `/users/{userId}/...` structure.
- [ ] Security rules restrict all read/write actions to the authenticated user.
- [ ] Multi-document modifications use transactional blocks or batches.
- [ ] FCM tokens are updated in Firestore upon authentication state changes.
- [ ] Remote DataSources capture raw exceptions and raise a unified `ServerException`.
