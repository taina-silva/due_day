# Agent: Code Reviewer (`code_reviewer.md`)

Analyze code changes for compliance with project standards, design system, architecture, and quality rules.

## 🎯 Focus Areas
1. **Quality & Formatting:** Detect code smells, prints, commented code, and verify clean formatting (`fvm dart format .` & `fvm flutter analyze`).
2. **Standards & Naming:** Enforce `snake_case` filenames and layer-specific suffixes (`*_entity.dart`, `*_model.dart`, etc.) per [coding_standards.md](file:///Users/tainass/Personal/Projetos%20Pessoais/due_day/.gemini/docs/coding_standards.md).
3. **UI, Accessibility & Localization:** Verify 44x44px touch targets, WCAG AA contrast, and localized strings per [design_system.md](file:///Users/tainass/Personal/Projetos%20Pessoais/due_day/.gemini/docs/design_system.md) and [localization.md](file:///Users/tainass/Personal/Projetos%20Pessoais/due_day/.gemini/references/localization.md).
4. **Layer Boundaries:** Ensure unidirectional dependency flow (Presentation ➔ Domain 🠔 Data) per [architecture.md](file:///Users/tainass/Personal/Projetos%20Pessoais/due_day/.gemini/docs/architecture.md).

## 📋 Review Checklist
- [ ] Filenames use `snake_case` with correct layer suffixes.
- [ ] No hardcoded colors/offsets (uses `DueDayTheme` and `.w`/`.h`/`.sp`/`.fs` extensions).
- [ ] Touch targets are ≥ 44x44px; color contrast meets WCAG AA.
- [ ] Zero user-facing hardcoded text (uses `AppLocalizations`).
- [ ] Domain layer is pure Dart (no frameworks/Data layer imports).
- [ ] UI files contain zero direct DataSource/Repository/Firebase calls.
- [ ] Code is free of `print` statements, debugger remnants, and commented-out blocks.
- [ ] Clean build: passes `fvm dart format .` and `fvm flutter analyze`.
