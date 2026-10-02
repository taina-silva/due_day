---
name: create-screen
description: Use when building a new page or widget in DueDay's Presentation layer. Covers DueDayTheme design tokens, responsive sizing extensions (.w/.h/.sp/.fs), localization, and touch-target accessibility.
---

# Create Screen

## Rules

- Tokens only, via `context.colors` / `spacing` / `typography` / `radius`. No `Colors.*`, no literal `EdgeInsets.all(16)` ([design_system.md](../../docs/design_system.md)).
- Every numeric dimension uses `.w` / `.h` / `.sp` / `.fs` (or `.width` / `.height` / `.scale`).
- Every text comes from `AppLocalizations.of(context)`.
- Touch targets ≥ 44x44.
- Feedback only through `AppMessenger`.
- Read lists from the feature's `XLoadBloc`.

## Page template

```dart
class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = AppLocalizations.of(context);

    return CustomScaffold(
      appBar: CustomAppBar(title: l10n.accountsTitle),
      body: BlocBuilder<AccountLoadBloc, AccountLoadState>(
        builder: (context, state) => switch (state) {
          AccountLoading() => const Center(child: CircularLoadingPrimary()),
          AccountError(:final failure) => Center(
              child: Text(failure.toLocalizedString(context),
                  style: typography.body.medium.copyWith(color: colors.system.error)),
            ),
          AccountLoaded(:final accounts) => ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: spacing.large.width, vertical: spacing.medium.height),
              itemCount: accounts.length,
              separatorBuilder: (_, __) => SizedBox(height: spacing.mediumLarge.height),
              itemBuilder: (_, i) => AccountCard(account: accounts[i]),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
```

## Bottom sheets with mutating actions

Never `pop()` right after dispatching. A `BlocListener` on the Action Bloc decides the outcome:

- **Error:** `AppMessenger.showError(...)`; the sheet stays open so the user can retry.
- **Success:** `Navigator.pop()`.
- Keep an `_isSubmitting` flag. It ignores states not caused by this submission (the Action Bloc is app-wide) and blocks double taps.

```dart
BlocListener<CategoryActionBloc, CategoryActionState>(
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
  child: Form(key: _formKey, child: /* fields + save button calling _submit */),
);

void _submit() {
  if (_isSubmitting || !_formKey.currentState!.validate()) return;
  setState(() => _isSubmitting = true);
  context.read<CategoryActionBloc>().add(AddCategoryEvent(/* ... */));
}
```

Test both branches: [testing.md](../../docs/testing.md#mutating-bottom-sheet).
