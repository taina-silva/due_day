# Localization

- Languages: **pt-BR** (default) and **en**.
- Catalogs: `lib/core/l10n/app_pt.arb` and `app_en.arb`. Every key goes in **both**.
- Keys: camelCase prefixed by feature — `authLoginTitle`, `accountsEmptyState`, `transactionsAmount`.
- After editing: `fvm flutter gen-l10n`.
- Use: `final l10n = AppLocalizations.of(context);` then `l10n.authLoginTitle`.
- No user-facing hardcoded strings anywhere, including notification channels and texts.
