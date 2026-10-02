# Navigation

GoRouter, defined in `lib/core/navigation/app_router.dart` (`createAppRouter(authBloc)`). Recipe: [add-route](../skills/add-route/SKILL.md).

## Auth guard

`refreshListenable: GoRouterRefreshStream(authBloc.stream)` re-runs `redirect` on every auth change:

- Auth still resolving → stay on `/` (splash).
- Unauthenticated → protected routes redirect to `/login`.
- Authenticated → `/`, `/login`, `/signup` redirect to `/dashboard`.

## Structure

- **Root routes** (full screen, no bottom nav): `/`, `/login`, `/signup`, `/profile`, `/notifications`, `/transactions/import`.
- **Tabs** (`StatefulShellRoute.indexedStack`, each with its own navigator key, so state is kept per tab): `/dashboard`, `/transactions` (+ `history`, `schedule`), `/accounts`, `/categories`.

A page that needs its own bottom action bar must be a root route — shell routes sit under the floating bottom nav.

## Usage

```dart
context.go('/dashboard');            // switch tab / reset stack
context.push('/profile');            // push on top
context.pop();
context.go('/categories', extra: true); // pass params via state.extra
```

Never use `Navigator.push`.
