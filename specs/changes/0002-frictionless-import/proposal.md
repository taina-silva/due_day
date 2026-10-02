# 0002 — Frictionless import

Status: proposed (draft; `/spec-propose 0002` writes `spec-delta.md` and `tasks.md`)

Depends on: `0001`.

## Why

Import is the main input (D4) and should take ~5 minutes a week. Today every item arrives uncategorized (`build_review_list.dart`), so 60 card purchases mean 60 taps. Scheduled bills get duplicated when they show up in the statement, and getting the file into the app takes several steps.

## What

- **Learned rules (D7):** categorizing an item saves `normalized memo → category` (lowercase, no accents or digits, main merchant prefix). Future imports arrive pre-categorized; changing a category overwrites the rule. Seeds: card bill payment → *Ignored*; transfers to XP / Inter / Mercado Pago → *Investment*.
- **Review list:** "Uncategorized" filter first. Uncategorized imports are still allowed.
- **Matching (D9):** candidate = unpaid expense, due within ±5 days, amount within ±15%. Default action: mark the scheduled item as paid (statement date and amount, keep category, store `externalId`). Several candidates → user picks; "Not this one" → import as new.
- **"Open with DueDay" (Android):** intent filter for `.csv` / `.ofx` that opens the review directly.
- **Sunday reminder:** 19:00 local notification that opens the import; can be turned off in Settings.
- **"+ New account"** inside the import account selector.

## Out of scope

Rule management screen, iOS "Open with", other banks.

## Impacted capabilities

`statement-import`, `categories`, `schedule-and-reminders`.
