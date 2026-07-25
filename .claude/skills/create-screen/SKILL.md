---
name: create-screen
description: Use when building a new page or widget in DueDay's Presentation layer. Covers DueDayTheme design tokens, responsive sizing extensions (.w/.h/.sp/.fs), localization, and touch-target accessibility.
---

# Standard Procedure: Create Screen

This guide describes how to build page layouts and widgets in the **Presentation Layer** of **DueDay** using design tokens, responsiveness, and localization.

---

## 🛠️ Screen Coding Rules

1.  **Strict Styling Constraints:** Never use standard Flutter styles (`Colors.white`, custom padding offsets like `EdgeInsets.all(16.0)`). Always reference `DueDayTheme` parameters.
2.  **Ensure Fluid Responsiveness:** Every numeric layout dimension (padding, margin, width, height, font size) must use the responsive layout extensions (`.w`, `.h`, `.sp`, `.fs`).
3.  **Localize User-Facing Content:** Load all texts from `AppLocalizations` translation keys. E.g., do not write `Text('Settings')` directly.
4.  **Touch Target Accessibility:** Ensure interactive buttons have a touch surface of at least **44x44px** to align with accessibility standards.
5.  **Never Dismiss a Mutating Bottom Sheet Eagerly:** if a bottom sheet dispatches an add/update/delete event, it must not `Navigator.pop()` right after dispatching it — see "Bottom Sheets with mutating actions" below.

---

## 📝 Page Blueprint Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/design_system/components/structure/custom_app_bar.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import '../../bloc/account_bloc.dart';
import '../../bloc/account_state.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Recover theme tokens using BuildContext extension
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    // 2. Recover localized translations
    final l10n = AppLocalizations.of(context);

    return CustomScaffold(
      appBar: CustomAppBar(
        title: l10n.accountsTitle,
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AccountError) {
            return Center(
              child: Text(
                state.message,
                style: typography.body.medium.copyWith(color: colors.system.error),
              ),
            );
          }

          if (state is AccountLoaded) {
            return ListView.separated(
              // Use responsive extensions on all dimensions
              padding: EdgeInsets.symmetric(
                horizontal: spacing.largeExtraLarge.width,
                vertical: spacing.medium.height,
              ),
              itemCount: state.accounts.length,
              separatorBuilder: (_, __) => SizedBox(height: spacing.mediumLarge.height),
              itemBuilder: (context, index) {
                final account = state.accounts[index];
                return Container(
                  height: 80.scale, // Scale uniform container
                  decoration: BoxDecoration(
                    color: colors.lightSurface,
                    borderRadius: BorderRadius.circular(
                      DueDayTheme.dimensions.radius.medium,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      account.name,
                      style: typography.title.small.copyWith(
                        color: colors.onLightBackground,
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

---

## 📝 Bottom Sheets with mutating actions

A bottom sheet that submits an add/update/delete must not close as soon as it dispatches the event — it has no way yet to know whether the write succeeded. Instead, dispatch the event, keep the sheet open, and let a `BlocListener` on the feature's Action Bloc (see [create-bloc](../create-bloc/SKILL.md)) decide the outcome:
- **On the error state:** call `AppMessenger.showError` with the localized failure and keep the sheet open so the user can retry without re-entering the form.
- **On the success state:** `Navigator.pop()`.
- **Guard with a local `_isSubmitting` flag**, both to ignore state changes that aren't a response to *this* submission (the Action Bloc is a shared, app-wide instance — see [dependency_injection.md](../../references/dependency_injection.md)) and to stop the user from double-submitting while a request is in flight.

```dart
class _AddEditCategoryBottomSheetState extends State<AddEditCategoryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryActionBloc, CategoryActionState>(
      listener: (context, state) {
        if (!_isSubmitting) return;

        if (state is CategoryActionError) {
          setState(() => _isSubmitting = false);
          AppMessenger.showError(context, state.failure.toLocalizedString(context));
        } else if (state is CategoryActionSuccess) {
          _isSubmitting = false;
          Navigator.of(context).pop();
        }
      },
      child: Form(
        key: _formKey,
        child: /* ...form fields..., CategoryFormActions(onSave: _submit) */,
      ),
    );
  }

  void _submit() {
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      context.read<CategoryActionBloc>().add(AddCategoryEvent(/* ... */));
      // No Navigator.pop() here — the BlocListener above closes the sheet.
    }
  }
}
```

Test both branches explicitly by driving the mocked Action Bloc's state stream after the tap (`whenListen` + a `StreamController`) — see [testing.md §4.1](../../docs/testing.md#41-testing-a-mutating-bottom-sheet-submit--stays-open-on-error--closes-on-success).
