# Statement import

## Purpose
Bring Nubank statements into the app with the least effort and without duplicates.

## Requirements

### IMP-001: Any file can be picked
The picker accepts any file. The format is validated after reading; a file that isn't a supported statement shows "unsupported file" and nothing is imported.

#### Scenario: OFX on Android
- **Given** an Android device and a Nubank `.ofx` file
- **When** the user opens the picker
- **Then** the file can be selected and is parsed

#### Scenario: a PDF
- **When** the user picks a `.pdf`
- **Then** an "unsupported file" error is shown

### IMP-002: Encoding fallback
File bytes are decoded as UTF-8 (BOM removed); if that fails, as Latin-1.

#### Scenario: Latin-1 CSV
- **Given** a CSV saved in Latin-1 with "Descrição" and "Padaria São João"
- **When** it is imported
- **Then** the header is recognized and the memo reads "Padaria São João"

### IMP-003: Format detected by content
The format is detected from the content, not the file name:
- **Checking OFX:** contains `<OFX>` (or `OFXHEADER`).
- **Checking CSV:** header `Data,Valor,Identificador,Descrição`.
- **Card bill CSV:** header `date,title,amount`.

Anything else is unsupported (IMP-001).

#### Scenario: renamed file
- **Given** a card bill CSV renamed to `fatura.txt`
- **When** it is imported
- **Then** it is parsed as a card bill

### IMP-004: Matching account type first
After parsing, the account picker lists accounts of the matching type first: `checking` for checking OFX/CSV, `credit_card` for card bills. Other accounts are still selectable.

#### Scenario: card bill
- **Given** accounts "Nubank" (checking) and "Nubank card" (credit card)
- **When** a card bill is parsed
- **Then** "Nubank card" is listed first

### IMP-005: Card bill lines
In a card bill CSV, `date` is `yyyy-MM-dd` and `amount` uses `.` as decimal separator. A positive amount is a purchase (expense); a negative amount is a credit (income). Rows with an invalid date or amount are skipped.

#### Scenario: purchase and refund
- **Given** rows `2026-09-03,Padaria,25.90` and `2026-09-05,Estorno Loja,-40.00`
- **Then** an expense of R$ 25.90 on 2026-09-03 and an income of R$ 40.00 on 2026-09-05 are listed

### IMP-006: Card bill dedup id
A card bill line's external id is built from its raw date, title, amount in cents, and its occurrence index among identical (date, title, amount) lines in the same file. Re-importing the same file creates nothing new; two identical purchases on the same day are both kept.

#### Scenario: two coffees
- **Given** two rows `2026-09-03,Cafe,8.00`
- **When** the file is imported twice
- **Then** the first import creates 2 transactions and the second creates none

### IMP-007: Card purchases dated on purchase, installments by month billed
Card purchases are paid transactions dated on the line's date. A title with an installment marker `N/M` (e.g. `Loja X - Parcela 3/10`) is dated line date + (N−1) months (day clamped to the month's last day). The external id still uses the raw line date.

#### Scenario: third installment
- **Given** row `2026-06-15,Loja X - Parcela 3/10,100.00`
- **Then** the expense is dated 2026-08-15

#### Scenario: day clamping
- **Given** row `2026-01-31,Loja Y - Parcela 2/3,50.00`
- **Then** the expense is dated 2026-02-28

### IMP-008: Bill payment pre-categorized as Ignored
The card bill payment in a checking statement (memo starting with "Pagamento de fatura") and the payment received in a card bill (title starting with "Pagamento recebido") arrive in the review list already categorized as *Ignored*, case- and accent-insensitive. The user can change it.

#### Scenario: checking statement
- **Given** a checking line "Pagamento de fatura" of −R$ 2,000
- **Then** it appears in review as an expense in *Ignored*

#### Scenario: card bill
- **Given** a card line `2026-09-10,Pagamento recebido,-2000.00`
- **Then** it appears in review as income in *Ignored*

### IMP-009: Other card credits arrive uncategorized
Negative card lines that aren't the bill payment (refunds, chargebacks) arrive as uncategorized income.

#### Scenario: refund
- **Given** `2026-09-05,Estorno Loja,-40.00`
- **Then** it is listed as uncategorized income

### IMP-010: Import doesn't touch accounts
Confirming an import writes only transactions (and category counters). The chosen account is stored on each transaction; no account document changes.

#### Scenario: confirming 30 items
- **When** an import of 30 items is confirmed
- **Then** 30 transactions are written and no account document is updated
