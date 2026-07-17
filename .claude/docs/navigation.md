# Application Routing & Navigation (navigation.md)

This document explains the routing system of **DueDay**, which uses **GoRouter** to manage app routes, stateful nested pages, and auth-dependent navigation guards.

---

## 🔀 1. Router Setup (`app_router.dart`)

Routing is managed in `lib/core/navigation/app_router.dart` and initialized inside `lib/main.dart` with `createAppRouter(AuthBloc)`.

### Root & Branch Navigators
To support nested navigation and separate navigation histories (e.g., maintaining scroll positions and state across bottom tabs), the router uses separate navigator keys:
- **`_rootNavigatorKey`**: The main parent navigator for full-screen pages (Splash, Login, SignUp, Profile, Notifications).
- **`_shellNavigatorHome` / `_shellNavigatorTrans` / `_shellNavigatorAcc` / `_shellNavigatorCat`**: Sub-navigators for bottom-navigation branches.

---

## 🔐 2. Dynamic Authentication Guard

The router listens directly to the authentication stream to trigger automatic navigation redirection when auth states change.

### Listening to Stream (`GoRouterRefreshStream`)
The stream is set up using:
```dart
refreshListenable: GoRouterRefreshStream(authBloc.stream),
```

### Redirect Logic
Redirection rules enforce strict page access:
1.  **Loading Guard:** While `AuthBloc` resolves the initial user state (`AuthInitial` or `AuthLoading`), the app forces the user to remain on the splash page `/` (or `/login`/`/signup` if they are entering credentials).
2.  **Redirecting Unauthenticated Users:** If the stream emits an unauthenticated state, any attempt to access a protected page redirects to `/login`.
3.  **Redirecting Authenticated Users:** If the user is authenticated, accessing `/` or auth pages (`/login`, `/signup`) automatically redirects to `/dashboard`.

---

## 📱 3. Stateful Bottom Navigation (`StatefulShellRoute`)

DueDay maintains tab states (e.g. scroll position, forms filled) when the user navigates between bottom-navigation items. This is implemented via `StatefulShellRoute.indexedStack`.

### Bottom Nav Branches:
1.  **Tab 0: Home** (`/dashboard`)
    - Displays consolidated balance cards and summaries.
2.  **Tab 1: Transactions** (`/transactions`)
    - Nesting routes:
      - `/transactions/history` — All past transactions filter list.
      - `/transactions/schedule` — Upcoming schedules timeline.
3.  **Tab 2: Accounts** (`/accounts`)
    - Listing and editing of bank accounts.
4.  **Tab 3: Categories** (`/categories`)
    - Listing and selection of transaction categories.

---

## ⚡ 4. Routing Best Practices

- **Declare Routes Declaratively:** Use GoRouter parameters when navigating to pass IDs and configurations. Avoid traditional `Navigator.push`.
- **Navigation Syntax:**
  ```dart
  // Go to root/tab level (resets branch stack)
  context.go('/dashboard');

  // Push full-screen modal or detailed sub-route
  context.push('/profile');

  // Pop current screen
  context.pop();
  ```
- **Context Extra:** When routing requires parameters (e.g., passing a selection mode to the categories screen), pass objects or booleans via `state.extra`.
  ```dart
  context.go('/categories', extra: true);
  ```
