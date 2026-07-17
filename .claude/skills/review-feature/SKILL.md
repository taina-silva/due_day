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
