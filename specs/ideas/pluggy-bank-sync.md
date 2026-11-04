# Idea — Bank sync via Meu Pluggy

Status: idea (needs a spike). Not a change; nothing here is approved. Recorded 2026-11-03.

## Why

Import (D4) still needs a weekly manual step: download the Nubank statement and card bill, then open them in DueDay. Meu Pluggy reads the user's own accounts through Open Finance and can expose them via API for free, which could turn the weekly import into one tap.

## What we know

- **Meu Pluggy** (meu.pluggy.ai) is a free consumer portal: connect banks via Open Finance (Nubank supported), view and export data.
- **API access** needs a Pluggy developer account (Dashboard), which starts a **15-day trial**. The free **MeuPluggy connector** keeps reading the holder's own data after the trial.
- Free-connector limits: own data only (no product for other users), **no SLA**, no automatic categorization, **max 5 active connections**.
- `client_id` / `client_secret` give full data access; Pluggy says to keep them server-side. The API key lasts 2 hours (`POST /auth`).
- Each bank is authorized once through the Dashboard's Demo app; that yields an **Item ID**. Data refreshes daily, without guarantees.
- **Open:** a third-party guide says the connector list can't be edited after the trial. It's unclear whether a bank can be added or an expired Open Finance consent re-authorized after that.

## Decisions (if it goes ahead)

| # | Decision | Why |
| :--- | :--- | :--- |
| P1 | Starts only after "MVP done" (`product.md`) | Validate the weekly habit first; keep a no-SLA dependency off the MVP path |
| P2 | First task of the future change is the spike | Answers below decide whether to build |
| P3 | MVP changes `0001`–`0004` stay as they are | Data shape unknown; `importSource` already tells sources apart |
| P4 | Pluggy is the **primary** source; file import stays as **fallback**, same pipeline and review list | Consents expire and there's no SLA; one default path keeps effort low |
| P5 | Credentials (`client_id`, `client_secret`, Item IDs) entered in Settings, stored in `flutter_secure_storage`; app calls the API directly | Single user who owns the keys; no backend or Blaze plan; nothing in the repo or binary |
| P6 | Sync on demand ("+" → Import → Sync), through the review list; the Sunday reminder opens sync | Matching (D9) sometimes needs a choice; reuses the MVP flow |
| P7 | Cross-source dedup by a **per-account cutoff**: fetch from the last confirmed item − 3 days; drop items whose Pluggy id already exists. No fuzzy dedup | Predictable; fuzzy dedup would merge two identical same-day purchases |
| P8 | Each Pluggy account is **linked once** to a DueDay account (existing or "+ New account"); unlinked accounts are skipped | Avoids duplicate accounts and per-sync choices; skips investment accounts for free |
| P9 | On Pluggy failure (expired consent, API or credential error), sync shows the reason and offers "Import file" | Makes the fallback reachable in one tap |
| P10 | If the spike shows re-authorization after the trial is impossible, or card items lack the purchase date, re-evaluate before any code | Cheaper alternative: a parser for Meu Pluggy's spreadsheet export |

## Spike questions

1. Can a bank be added or a consent re-authorized after the trial ends?
2. Do card transactions carry the purchase date (D5) and installment info?
3. Are descriptions close enough to the CSV memo for learned rules (D7) to work for both sources?
4. Is there a stable id per transaction (future `externalId`)?
5. How often does the same item arrive from both sources around the cutoff?
6. Does Pluggy return the card's due day (to prefill `dueDay`)?

## Sources

- [Meu Pluggy](https://meu.pluggy.ai/en)
- [Pluggy pricing](https://www.pluggy.ai/precos)
- [pluggyai/meu-pluggy README](https://github.com/pluggyai/meu-pluggy)
- [Pluggy authentication](https://docs.pluggy.ai/docs/authentication)
- [Actual Budget: Pluggy bank sync](https://actualbudget.org/docs/advanced/bank-sync/pluggyai)
