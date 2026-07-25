---
name: review-feature
description: Use as a checklist when reviewing a DueDay feature implementation or code submission. Covers architectural integrity, design-system/token compliance, clean-code/localization rules, and test/analyze checks.
---

# Standard Procedure: Review Feature

This checklist outlines the criteria for reviewing feature implementations and code submissions in **DueDay**.

---

## 📋 Code Review Checklist

### 1. Architectural Integrity
- [ ] No Presentation-layer widgets or pages access Repositories or DataSources directly (everything flows through BLoC ➔ UseCase).
- [ ] UseCases reside in the Domain layer and contain no Flutter, Firebase, or external library imports.
- [ ] DataSources handle raw database interactions and propagate exceptions instead of returning Either.
- [ ] Repositories catch exceptions and return `Either<Failure, T>`, mapping raw exceptions to typed domain `Failure`s (ensuring no raw exceptions or strings reach BLoC/UI).
- [ ] Every repository catch block logs via `ObservabilityService.error(...)` before mapping to `Left(Failure)`, tagged with the feature name (see [observability.md](../../docs/observability.md)).
- [ ] No `ObservabilityService` call logs a full entity/state object (`.toString()` dump) — only short messages and explicit `error`/`context` values, since DueDay handles financial data.
- [ ] Any feature with a real-time list stream **and** mutating actions splits into `XLoadBloc` + `XActionBloc` (not one bloc emitting both) — see [architecture.md](../../docs/architecture.md#load-bloc--action-bloc-separation-standard-for-streamed-features).
- [ ] Error states are named `XError` (never `XFailure`); action blocs emit `XActionInProgress` before the result so two consecutive identical failures both reach the UI.
- [ ] Bottom sheets that dispatch add/update/delete never `Navigator.pop()` right after dispatching — they pop only from a `BlocListener` on the Action Bloc's success state, and show `AppMessenger.showError` (keeping the sheet open) on its error state.
- [ ] No raw `SnackBar`/`ScaffoldMessenger` calls — only `AppMessenger.showSuccess/showError/showInfo`.

### 2. Design System & Layout Tokens
- [ ] No hardcoded colors (`Colors.white` or hex literals) are used in UI code. All colors reference `DueDayTheme.colors`.
- [ ] No hardcoded spacings, margins, or padding values. All dimensions reference `DueDayTheme.dimensions`.
- [ ] All numeric layouts scale dynamically using responsive extensions (`.w`, `.h`, `.sp`, `.fs`).
- [ ] Interactive components (buttons, links) have a minimum touch target area of **44x44px**.
- [ ] Color combinations meet **WCAG AA** accessibility contrast criteria.

### 3. Clean Code & Project Rules
- [ ] File names are written in `snake_case`.
- [ ] All user-facing strings are localized using `AppLocalizations` (no hardcoded strings).
- [ ] Translation keys follow the camelCase `featureNomeChave` naming convention.
- [ ] No dead imports, unused imports, commented-out code blocks, or print statements are left in modified files.
- [ ] All modified files are formatted with `fvm dart format .`.

### 4. Tests & Analysis
- [ ] `fvm flutter analyze` passes cleanly with zero warnings or errors resolved in modified files.
- [ ] Unit and BLoC tests cover success and failure paths.
- [ ] `fvm flutter test` passes successfully.
