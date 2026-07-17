---
name: add-route
description: Use when adding a new page/route or navigating between screens in DueDay. Covers declaring GoRoute entries in app_router.dart (standalone vs nested shell-branch routes) and the go/push/pop/extra navigation API.
---

# Standard Procedure: Add Route

This guide describes how to declare, parameterize, and navigate to new pages using **GoRouter** in **DueDay**.

---

## 🛠️ Route Registration Recipe

### Step 1: Open `app_router.dart`
Open `lib/core/navigation/app_router.dart`. Determine where the route should be placed:
- **Standalone Route:** Full-screen pages (e.g. settings overlay) are added directly to the main `routes` list.
- **Nested Tab Route:** Added to a specific `StatefulShellBranch` inside the `branches` list of the main bottom shell route.

### Step 2: Declare the Route
Add the path, key details, and builder method:
```dart
GoRoute(
  path: '/transaction-detail/:id',
  name: 'transaction_detail',
  builder: (context, state) {
    // Extract route parameter
    final transactionId = state.pathParameters['id']!;
    
    // Extract query parameter or extras
    final isEditable = state.uri.queryParameters['edit'] == 'true';

    return TransactionDetailPage(
      transactionId: transactionId,
      isEditable: isEditable,
    );
  },
)
```

---

## 🚀 Navigation Commands

Use GoRouter methods on `BuildContext` to navigate:

### 1. Simple Go (Resets history branches if target is outside stack)
```dart
context.go('/dashboard');
```

### 2. Full-Screen Push (Overlays a route over current context)
```dart
context.push('/transaction-detail/123?edit=true');
```

### 3. Pop Screen
```dart
context.pop();
```

### 4. Passing complex objects
If you need to pass a complex object (like a full model class or callback function), send it through `extra`:
```dart
context.push('/edit-account', extra: accountEntity);

// Read extra inside app_router.dart:
final account = state.extra as AccountEntity;
```
