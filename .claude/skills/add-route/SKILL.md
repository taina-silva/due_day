---
name: add-route
description: Use when adding a new page/route or navigating between screens in DueDay. Covers declaring GoRoute entries in app_router.dart (standalone vs nested shell-branch routes) and the go/push/pop/extra navigation API.
---

# Add Route

In `lib/core/navigation/app_router.dart` ([navigation.md](../../docs/navigation.md)):

- **Full screen** (no bottom nav, or has its own bottom bar): add to the root `routes` list.
- **Inside a tab:** add to that tab's `StatefulShellBranch`.

```dart
GoRoute(
  path: '/transaction-detail/:id',
  builder: (context, state) => TransactionDetailPage(
    transactionId: state.pathParameters['id']!,
    isEditable: state.uri.queryParameters['edit'] == 'true',
  ),
)
```

## Navigate

```dart
context.go('/dashboard');                         // switch tab / reset stack
context.push('/transaction-detail/123?edit=true'); // push on top
context.pop();
context.push('/edit-account', extra: account);    // objects via extra → state.extra as AccountEntity
```
