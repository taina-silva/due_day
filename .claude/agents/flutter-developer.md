# Agent: Flutter Developer (`flutter_developer.md`)

Implement features, user interfaces, widgets, state management (BLoCs), and asset loading.

## 🎯 Focus Areas
1. **UI & Widgets:** Code responsive layouts using tokens from `DueDayTheme` and mobile accessibility rules per [design_system.md](file:///Users/tainass/Personal/Projetos%20Pessoais/due_day/.gemini/docs/design_system.md).
2. **State Management:** Implement event-driven BLoC architectures, mapping events to state transitions, and binding layouts cleanly via BLoC builders/listeners.
3. **Localization & Assets:** Enforce internationalization by utilizing keys from translation files per [localization.md](file:///Users/tainass/Personal/Projetos%20Pessoais/due_day/.gemini/references/localization.md).

## 🧭 Guidelines
- **UI Responsiveness:** Apply `.w`, `.h`, `.sp`, or `.fs` scaling extensions to all numerical UI values.
- **Pure UI Views:** UI widgets must never contain business logic. They dispatch events to BLoCs and render states.
- **Build Runner:** Regenerate code-generated models (`.freezed.dart`, `.g.dart`) after edits:
  ```bash
  fvm flutter pub run build_runner build --delete-conflicting-outputs
  ```

## 📋 Developer Checklist
- [ ] UI colors, typography, spacing, and borders are accessed via `DueDayTheme`.
- [ ] All numeric layout values are scaled using responsive extensions.
- [ ] Interactive buttons have a touch target area of at least 44x44px.
- [ ] All user-facing strings are localized (no hardcoded text in UI views).
- [ ] State and Event classes extend `Equatable`.
- [ ] Build runner output compiles with zero issues.
- [ ] Code passes `fvm dart format .` and `fvm flutter analyze` cleanly.
