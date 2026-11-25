# SpendWise Growth Master Plan — v2.4 "Relaunch"

> Single source of truth for the relaunch: decisions, scope, ASO, launch and metrics.
> Started 2026-10-24. Scope widened on 2026-11-10 (D15–D24). Audit decisions and the step-by-step build order added on 2026-11-18 (D25–D35, [BUILD_ORDER.md](BUILD_ORDER.md)). Spanish and receipt scanning dropped on 2026-11-22 (D36, D37). Update the **Decision log** and tick the checklists as work lands.

**Contents:** 1. Where we are · 2. Goals · 3. Decision log · 4. Positioning · 5. Free vs Pro & pricing · 6. v2.4 scope · 7. Build order & timeline · 8. Naming · 9. ASO & metadata · 10. Screenshots & icon · 11. App Review & release checklist · 12. Launch & growth · 13. Measurement · 14. Risks · 15. Open questions · 16. Out of scope · Appendix A–C

---

## 1. Where we are (baseline, 2026-10-24)

Live since 2026-08-25 as **"SpendWise: Budgets & Cards"** (App Store id `6756066717`), built from commit `80917e6` ("version2.3"), which the upgrade test in [docs/upgrade-test](upgrade-test/README.md) builds. No update since 2026-08-26.

| Metric (launch → 2026-10-24) | Value | Read |
|---|---|---|
| Impressions | 974 (~16/day) | Almost invisible in search |
| Product page views | 63 (6.5% tap-through) | OK |
| First-time downloads | 18 (28.6% of page views) | Close to the ~33% finance benchmark |
| Paying users / MRR | ~1 / $3 | Too small to judge |
| Ratings | 0 | No social proof |

**Why growth stalled:**
1. **Not discoverable.** The app is outside the top ~190 US results for every generic term, and #13 for its own name: 20+ other apps are called "SpendWise".
2. **Hard paywall on the core action.** Adding the first expense requires a subscription ([HomeView.swift:92](../SpendSnap/Views/Home/HomeView.swift), [HistoryView.swift:56](../SpendSnap/Views/History/HistoryView.swift)). So there are no free users, no ratings and no word of mouth.
3. **Slow first expense.** No default categories are created, and onboarding asks for nothing.
4. **Listing problems.** Screenshots show personal data in Rs on the US store. The icon is generic. "Never miss a card due date" is promised, but there are no due-date alerts.

---

## 2. Goals

Initial targets for **2027-01-31**. Reset them after two weeks of 2.4 data.

| Metric | Baseline | Target |
|---|---|---|
| Impressions / day (all stores) | ~16 | 150+ |
| Page view → download | 28.6% | ≥ 30% |
| Ratings | 0 | 50+ (avg ≥ 4.5) |
| Download → trial start | n/a | ≥ 15% |
| Release cadence | none since Aug | an update every 2–4 weeks after 2.4 |

**Timing anchor:** January is the biggest month for budgeting-app downloads. 2.4 must be live before 2026-12-28.

---

## 3. Decision log

| # | Date | Decision |
|---|---|---|
| D1 | 2026-10-24 | **Rename the app.** "SpendWise" can't be owned in search. Bundle ID, iCloud container, App Group and subscriptions stay the same. |
| D2 | 2026-10-24 | **Freemium.** Manual logging is free. Pro covers the differentiators (see §5). |
| D3 | 2026-10-24 | **iCloud sync stays free.** It's the user's backup on an iPhone-only app, and gating it risks data loss and 1★ reviews. |
| D4 | 2026-10-24 | **Add a Lifetime option.** Preselect Yearly on the paywall and show the saving. |
| D5 | 2026-10-24 | **No Apple Pay auto-logging.** It can't be tested in Pakistan. |
| D6 | 2026-10-24 | **No SMS / bank-notification logging.** Privacy-first. |
| D7 | 2026-10-24 | **Privacy-first is a hard rule.** All processing is on-device. No third-party AI and no analytics SDKs. The "Data Not Collected" label must stay true. |
| D8 | 2026-10-24 | **Credit card tracking is a core pillar.** It's packaged with recurring bills as **"Bills & Cards"**. |
| D9 | 2026-10-24 | **One big 2.4 release.** Scope in §6. Slip rule: anything not solid at code freeze moves to 2.5. |
| D10 | 2026-10-24 | **Languages for 2.4:** English, **Arabic, German** (app UI + store listing + Siri phrases). Spanish was on this list until D36. |
| D11 | 2026-10-24 | **Siri:** two-step flow on iOS 17–26, one-sentence where iOS 27's Siri supports it. Default payment method plus merchant memory. |
| D12 | 2026-10-24 | **"Mark statement as paid"** is in 2.4. Reminders stop once a cycle is paid. |
| D13 | 2026-10-24 | **Separate metadata per store.** Title, subtitle and keywords are written per localization and checked in AppTweak before release. |
| D14 | 2026-10-24 | **AppTweak quota.** OK to clear Claude's older AppTweak keyword lists to make room for the final metadata check (data is preserved in Appendix A). |
| D15 | 2026-11-10 | **Subscriptions view in 2.4** (Pro), built on recurring bills. "Subscription tracker" is high volume and near-zero difficulty in the US and UK (Appendix A), and the word is already in the keyword fields. |
| D16 | 2026-11-10 | **Face ID app lock in 2.4** (free). It gives the privacy pillar something the user can see. |
| D17 | 2026-11-10 | **Search in History in 2.4** (free). |
| D18 | 2026-11-10 | **Income tracking in 2.4** (free). "Money manager" is the top term in the UK, India, Pakistan and the UAE, and we expect those searchers to want income as well as spending (our inference, not measured). |
| D19 | 2026-11-10 | **Savings goals in 2.4**, moved up from §16. Free vs Pro split: D24. |
| D20 | 2026-11-10 | **Card payoff helper in 2.4** (Pro), moved up from §16. It backs the US "debt" and "payoff" keywords. |
| D21 | 2026-11-10 | **All widgets are free**, Home Screen and Lock Screen. Widget code has no Pro check today, and adding one means sharing entitlement state with the widget process. Closes Q5. |
| D22 | 2026-11-10 | **D5 re-confirmed.** Auto-logging through the Shortcuts Wallet automation was considered and declined: it can't be tested from Pakistan. |
| D23 | 2026-11-10 | **Build starts 2026-11-11.** No 2.4 code had landed by Nov 10, so §7 is re-dated. Freeze (Dec 4) and submit (Dec 7) are unchanged. |
| D24 | 2026-11-11 | **Savings goals: one goal is free, unlimited goals are Pro.** Closes Q7. |
| D25 | 2026-11-18 | **A card shows its last closed statement until that statement's due date.** Today the card jumps to the next cycle on statement day, so for about three weeks a month the bill actually due isn't shown. Found in the 2026-11-11 code audit, like D26–D28. |
| D26 | 2026-11-18 | **The monthly budget gets an "every month" default.** A month's own budget overrides it, the way category budgets already work. Today every month starts at zero. |
| D27 | 2026-11-18 | **Income is its own model**, not a flag on `Expense`. A phone still on 2.3 shares the same iCloud data and would count flagged income as spending. Settles the model choice in §6.8. |
| D28 | 2026-11-18 | **Deleting a category moves its expenses to "Other"**, and Other can't be deleted. Today the expenses are deleted along with the category. |
| D29 | 2026-11-18 | **Five tabs stay.** Cards becomes "Bills & Cards", savings goals live on Home, and the + button offers Expense and Income (Scan was dropped with D37). |
| D30 | 2026-11-18 | **Design kit first.** Shared colours, type, components and accessibility labels come before any new screen. Existing screens are restyled in the step where they gain features (§6.10). |
| D31 | 2026-11-18 | **Merchant memory comes from history.** A merchant gets the category of its most recent expense, else a bundled list of common merchants. No new model, so nothing to reconcile across devices. |
| D32 | 2026-11-18 | **Income sources are a fixed list:** Salary, Business, Freelance, Gift, Other. |
| D33 | 2026-11-18 | **Card-alert lead days are set per device**, like the Face ID lock (D16). |
| D34 | 2026-11-18 | **Work runs in small steps** of about 150 changed lines, 200 at most, in the order set by [BUILD_ORDER.md](BUILD_ORDER.md). The rules are in CLAUDE.md. |
| D35 | 2026-11-18 | **Free users can add credit cards as payment methods.** Cycles, due-date and statement alerts, mark-as-paid and the payoff plan stay Pro, so the onboarding card step works for everyone. Closes Q8. |
| D36 | 2026-11-22 | **Spanish is dropped from 2.4:** app, store listing and Siri phrases. Its keywords couldn't be researched once the AppTweak trial ended, and a listing built on guessed keywords doesn't repay the translation, review and screenshot work. Mexico and Spain keep the English listing. An optional Spanish (Mexico) listing can still carry extra English keywords for the US store (§9.1). Closes Q6. |
| D37 | 2026-11-22 | **Receipt scanning is dropped from 2.4.** It is slower than the logging 2.4 is built around (Siri, Control Center, the + button), most everyday spending has no usable receipt, and the faster extraction needs Apple Intelligence. It removes six build steps, the camera permission and the 20-receipt test. `receipt` and `scanner` leave the keyword fields (§9.2). |

---

## 4. Positioning

**One line:** *The private expense tracker that handles your credit cards: log in seconds, never miss a card or bill due date, and nothing leaves your iPhone.*

**Who it's for:** people who juggle cash, one or more credit cards, and monthly bills, and who won't (or can't) connect a bank. That's strongest where bank-sync apps don't work: Pakistan, India, the Gulf, plus privacy-minded users in the US, UK, Australia and Canada.

**The four pillars**
1. **Fastest manual logging.** Siri, Control Center, Lock Screen widget, Back Tap / Action Button, smart defaults. This is the proven hook: Tappy, launched June 2026, is a top-grossing finance app in India and Pakistan almost entirely on "log without opening the app".
2. **Bills & Cards.** Statement cycles, due-date alerts, mark-as-paid, a payoff plan, recurring bills, subscriptions and upcoming payments. The niche is unowned: dedicated card-tracker apps all have under 60 ratings, and the big card apps (CardPointers, MaxRewards) optimise rewards instead.
3. **Private by design.** No bank login, no account, Face ID lock, Data Not Collected, and everything is processed on the iPhone. Competitors often send entries to cloud AI (Quanto discloses a third-party AI service), so this is a claim most can't honestly copy.
4. **Built for your money.** 49 currencies, plus Arabic and German.

**Expected basics, not pillars (D17–D19):** income tracking, savings goals and search. People searching "money manager" and "savings tracker" expect them, so they ship in 2.4 but don't lead the pitch.

**What the research says about how to sell it** (details in Appendix A):
- Nobody searches for "statement date" or "billing cycle". People search **bills / debt / card manager**.
- Credit-card terms only have meaningful, uncontested volume in the **US** ("card manager" 34/d0, "credit card manager" 25/d9, "credit card tracker" 21/d0).
- **Privacy phrases have no search volume anywhere.** Privacy belongs in screenshots, the description and promo text, not in the title or keyword field.

---

## 5. Free vs Pro & pricing

| Free | Pro |
|---|---|
| Unlimited manual logging of expenses **and income** | Credit card cycles, due-date & statement alerts, mark as paid, **payoff plan** |
| Siri, Shortcuts & Control Center logging | Recurring expenses, bill reminders & **Subscriptions view** |
| Default + custom categories | Insights / trends and past-month history |
| Monthly budget | CSV export |
| Current-month overview, **with search** | **Unlimited savings goals** |
| **Home Screen & Lock Screen widgets** | |
| **One savings goal** | |
| **Face ID app lock** | |
| **Credit cards as payment methods** (D35) | |
| iCloud sync, light/dark mode, 49 currencies | |

Changed on 2026-11-10, 11 and 18 (D15–D21, D24, D35); new or moved items are in bold. On-device receipt scanning left Pro on 2026-11-22 (D37). **Widgets carry no Pro check.** The Credit Cards widget and the "next card due" Lock Screen widget read card data, so they show an empty state until the user has a card. Since free users can now add cards (D35), those two widgets show due dates to free users too (Q9).

**Prices**
- **Today:** $2.99/mo and $19.99/yr, with a 2-week free trial. The products are `sw1` and `sw2` in group `21928894`.
- **New in 2.4:** a Lifetime product at **$39.99**. This is a non-consumable with a new product ID, e.g. `sw_lifetime`.
- **Benchmarks:**
  - DaTrack: £4.99/mo, £29.99/yr, £69.99–99.99 lifetime
  - Fleur: A$9.99/mo, A$49.99–59.99/yr
  - Quanto: $2.99/mo, $24.99/yr, $59.99 lifetime
  - Tappy: ₹79 / ₹499 / ₹1,999
- **Open question Q2:** raise Yearly to $24.99–29.99 in the US, UK, Australia and Canada, and set lower local prices in Pakistan and India.

**Paywall rules**
- Shown once after onboarding, and it can be dismissed. The **+ button always works.**
- Yearly is preselected with a "$1.67/mo · save 44%" badge. Lifetime is clearly labelled as a one-time purchase.
- Show the trial timeline: "Today: full access → Day 12: reminder → Day 14: billed".
- The feature list shows Pro features only. Drop "Light and dark appearance" ([GoProSheet.swift:76](../SpendSnap/Views/Settings/GoProSheet.swift)).
- Copy explains what's free forever and what Pro adds. Tappy shipped this exact change in Oct 2026.

---

## 6. v2.4 scope

Each item has a **Done when** line. Tick the boxes as items land.

### 6.1 Monetization & first run
- [ ] **Free logging.** Remove the subscription gate from add-expense in Home and History. Gate the Pro features from §5 instead.
  - *Done when:* a fresh install with no subscription can log, edit and delete expenses. Every Pro entry point shows `GoProSheet`.
- [ ] **Entitlement model.** `StoreKitManager` grants Pro for an active `sw1`/`sw2` **or** the lifetime non-consumable. Rename `hasActiveSubscription` to `hasPro`.
  - *Done when:* sandbox tests pass for monthly, yearly, lifetime, restore, and a lapsed subscription.
- [ ] **Paywall rework** per §5.
- [ ] **Default categories on first run.** Seed from the existing `Category` enum plus "Other", using the `hasSeededDefaultCategories` flag (currently unused). It must be idempotent across synced devices.
  - *Done when:* a new user can log their first expense with zero setup, and two devices don't produce duplicate categories.
- [ ] **Onboarding setup.** Ask for currency (default from `Locale.current.currency` if supported), monthly budget, default payment method, and optionally the first card (statement and due day). Then show "Your plan is ready" and the paywall.
  - *Done when:* the steps can be skipped, and values persist to `Settings` and the models.
- [x] **Money formatting everywhere.** Use `.formatted(.currency(code:))` and drop raw `"\(symbol)\(amount)"` interpolation.
  - *Done when:* amounts show thousands separators and correct decimals, and Arabic-locale numerals render correctly.
- [ ] **Faster add-expense form.** Amount first. Merchant optional. Category chips visible without scrolling. Payment method defaults from Settings.
- [ ] **Review prompt.**
  - Call `requestReview` automatically after the 5th logged expense, or at the end of the first week under budget (rate-limited by iOS).
  - The "Rate us" row opens `https://apps.apple.com/app/id6756066717?action=write-review`.

### 6.2 Fast logging (Siri & system surfaces)
- [ ] **`LogExpenseIntent`** (App Intents, runs without opening the app).
  - Parameters: `text` (String, `requestValueDialog` "What did you spend?"), plus optional structured `amount`, `merchant`, `card` (AppEntity), `category` (AppEntity) and `method` (AppEnum).
- [ ] **Text parser** (on-device, deterministic, unit-testable):
  - Amount formats: "1500", "1,500", "15.50", "Rs 1500".
  - Merchant: after "at / for / on".
  - Payment: "cash", a card name, or the last 4 digits.
  - Category: from merchant memory, else "Other".
  - Must work in English, Arabic and German.
- [ ] **Default payment method** (Settings: Cash or a specific card). A card named in the request overrides it.
- [ ] **Merchant memory (D31).** A merchant gets the category of its most recent expense, else a bundled list of ~100 common merchants across PK/IN/Gulf/US/UK/EU, else Other. No new model.
- [ ] **Confirmation.**
  - Siri says "Logged Rs 1,500 · McDonald's · Dining · HBL card".
  - On iOS 26+, an interactive snippet adds *Change category* and *Undo* buttons.
- [ ] **App Shortcuts (Siri / Spotlight / Action Button / Back Tap).** Each must include the app name.
  - "Log an expense in *App*"
  - "How much have I spent this month in *App*"
  - "How much budget is left in *App*"
  - "When is my *card* due in *App*" (card as an AppEntity parameter)
  - Phrases localized in EN/AR/DE.
- [ ] **Control Center "Add expense" control** (iOS 18+, `@available`-gated). Opens straight to add-expense.
- [ ] **Lock Screen widgets** (accessory circular/rectangular/inline): left this month, next card due. Free (D21).
- [ ] **Setup guide screen** for Back Tap and the Action Button.
- *Done when:* "Hey Siri, log an expense in *App*" → "1500 at McDonald's on HBL" logs the correct amount, merchant, category and card, on iOS 17, 18, 26 and 27 test devices, in English and Arabic.
- *iOS 27:* reports say the new Siri can fill App Intent parameters from one sentence (English first, not in the EU at launch). We support it through the structured parameters and verify on device. It's not a release blocker.

### 6.3 Bills & Cards
- [ ] **Card due-date alerts:** 3 days and 1 day before the due date (lead days set per device, D33), plus a statement-close alert ("Statement closes tomorrow: Rs X this cycle"). Alerts follow the statement that is actually due (D25).
- [ ] **Mark statement as paid.**
  - Stored as **one record per card per cycle**, so two devices merge cleanly.
  - Reminders skip paid cycles.
  - The card shows *Paid / Due in N days / Overdue*.
  - The record stores the **amount paid**: in full, or a partial amount. An unpaid remainder is added to the card's amount owed for the payoff helper below.
- [ ] **Recurring expenses & bill reminders.**
  - New model with frequency (weekly / every 2 weeks / monthly / yearly), next due date, optional card, reminder lead time, an **is-subscription** flag, and whether it creates an expense or income (e.g. salary).
  - Expenses are created automatically on launch or foreground for every occurrence up to today.
  - An "Upcoming bills" section appears on Home.
- [ ] **Duplicate safety for recurring.** Each generated `Expense` carries a deterministic `recurrenceKey` (rule ID + occurrence date). A reconciler, modeled on `SettingsReconciler`, removes duplicates after iCloud sync.
  - *Done when:* two devices offline at the same time and then synced end with exactly one expense per occurrence.
- [ ] **Notification budget.** iOS allows at most 64 pending local notifications per app.
  - Schedule only the next occurrence per card and bill.
  - Reschedule on foreground and after edits.
  - Priority: card due, then bills, then logging reminders.
- [ ] **Subscriptions view (D15, Pro).**
  - A recurring rule can be flagged as a subscription.
  - A Subscriptions screen lists them with the next charge date and shows a monthly and a yearly total.
  - Totals normalise by frequency: weekly × 52 ÷ 12, every 2 weeks × 26 ÷ 12, yearly ÷ 12.
  - *Done when:* subscriptions of 5 a week, 10 a month and 120 a year show 41.67 a month and 500 a year, and each appears in "Upcoming bills".
- [ ] **Card payoff helper (D20, Pro).**
  - `CreditCard` gains amount owed, yearly rate (optional; 0 for Islamic and 0% cards) and planned monthly payment, all with defaults.
  - One pure function walks month by month (add a month's interest, subtract the payment). It returns the number of payments, the payoff date and the total interest, or "never" when the payment doesn't exceed one month's interest.
  - A "Payoff plan" section in `CardDetailSheet`: enter what's owed, adjust the monthly payment, and see the date and interest update.
  - Marking a statement as partly paid adds the remainder to the amount owed.
  - *Done when:* 200,000 owed at 36% a year with 20,000 a month gives 13 payments and about 41,350 interest; a payment of 6,000 or less shows a "never clears" warning; a zero rate gives 10 payments and no interest.

### 6.4 Receipt scanning: dropped (D37)
Dropped from 2.4 on 2026-11-22; the reasons are in D37. The section number stays so later references don't change. The app needs no camera permission.

### 6.5 CSV export (Pro)
- [ ] Columns: ISO date, type (expense / income), amount, currency code, merchant, category, method, card. RFC 4180 quoting, locale-independent decimals. Shared via `ShareLink` / `fileExporter`.

### 6.6 Localization (Arabic, German)
- [ ] **String Catalog** for the app and widget targets, **set up first** so every new string is localizable from day one.
- [ ] Convert the 56 computed/enum strings to `String(localized:)` / `LocalizedStringResource`. Replace `Text(verbatim:)` interpolations with formatted values.
- [ ] **Right-to-left QA in Arabic:** CustomTabBar, PieChart, PaceBandChart, DailyBurn, WeeklyBarRow, progress bars, card visuals and onboarding.
- [ ] **Onboarding images have baked-in English text** (`problem1–3`, `solution`). Replace them with text-free art and native text.
- [ ] AI draft translations, then **native-speaker review** for AR and DE (who reviews is open question Q4).
- *Done when:* the app runs fully in each language with no truncation, and Arabic mirrors correctly.

### 6.7 Rename
- [ ] Display name for the app and widgets, all in-app "SpendWise" strings, and "SpendWise Pro" → "*Name* Pro".
- [ ] In App Store Connect: app name per localization, the subscription group display name, and product display names.
- [ ] Privacy and terms pages: keep the old URLs working and add new ones. Support email optional.
- [ ] Internal identifiers **don't change**: bundle IDs, the `SpendWise://` URL scheme, the CloudKit container and the App Group.

### 6.8 Income, savings goals & everyday tools (added 2026-11-10)
- [ ] **Income tracking (D18, free).**
  - The add form gets an Expense / Income switch. Income has an amount, a date and a source from a fixed list (D32): Salary, Business, Freelance, Gift, Other.
  - Home shows income, spent and net for the month. "Left to spend" stays budget-based.
  - History lists income alongside expenses. Budgets, card cycles, the Insights spending charts, widgets and Siri's "how much have I spent" keep counting **spending only**.
  - Income is its own `Income` model (D27), so existing expenses are untouched and 2.3 devices never count income as spending.
  - *Done when:* adding income changes no spending total, budget bar, card cycle or widget figure; Home shows the three numbers; an upgrade from 2.3 leaves existing data untouched.
- [ ] **Savings goals (D19).**
  - New models: a goal (name, emoji, target amount, optional target date) and its contributions. Each contribution is **its own record**, so money added on two devices merges instead of overwriting.
  - Entry point: a Goals section on Home that opens the goal detail. No new tab.
  - The detail shows progress, the amount still needed, and "save X a month to reach it by *date*".
  - Contributions are not expenses and never count toward spending.
  - Free: one goal. Pro: unlimited (D24). A free user who tries to create a second goal sees `GoProSheet`.
  - A lapsed subscriber keeps every existing goal and can still add money to them, but can't create another.
  - *Done when:* a user can create a goal, add and remove money, and see progress and the monthly amount needed; two devices that add money offline show both contributions after sync.
- [ ] **Search in History (D17, free).** `.searchable` over the selected month, matching merchant, category and amount.
  - *Done when:* typing filters the list and clearing restores it; the screen still clears its cache on `.spendWiseDidDeleteAllData`.
- [ ] **Face ID app lock (D16, free).**
  - `LocalAuthentication` with `.deviceOwnerAuthentication`: Face ID or Touch ID, falling back to the device passcode.
  - A Settings toggle. The app locks on launch and on return from the background, and hides its content in the app switcher.
  - Stored **per device** (UserDefaults), not in the synced `Settings` row, so one device's lock doesn't lock another.
  - The toggle's footnote says that widgets and Siri answers still show amounts.
  - Add `NSFaceIDUsageDescription`.
  - *Done when:* with the lock on, nothing is visible before authentication on cold launch and after backgrounding; a cancelled or failed check leaves the app locked; a device with no passcode can't turn the lock on.

### 6.9 Fixes found in the code audit (2026-11-11)
The checks for each fix are in [BUILD_ORDER.md](BUILD_ORDER.md), steps 2.1–2.7 and 6.6.
- [ ] **Card statement due (D25).** The card, its widget and its alerts show the last closed statement until that statement's due date.
  - *Done when:* with statement day 1 and due day 21, the card shows July's total due 21 Aug from 1 to 21 Aug, then 21 Sep from 22 Aug.
- [x] **Amount entry in every locale.** `12,50`, `1.250,00` and Arabic digits are read correctly in every amount field. Today `12,50` saves as 1250 on phones that use a decimal comma, such as German ones, and Arabic digits can't be saved.
- [x] **The budget carries over (D26).** An "every month" budget applies to new months. On upgrade, the latest month's budget becomes the default.
- [x] **Reminders stop wiping other alerts.** Changing the reminder level removes only the logging reminders.
- [ ] **Deleting a category keeps its expenses (D28).**
- [ ] **Small fixes.**
  - A category can be created without a budget.
  - Silver and platinum cards get readable text.
  - A long merchant name is capped as you type instead of silently blocking save.

### 6.10 Design refresh (D29, D30)
- [ ] **Design kit.**
  - Colour tokens for light and dark.
  - A type scale on the system text styles.
  - Two corner radii.
  - Shared components: surface, buttons, sheet header, chips, progress bar, empty state, amount field.
- [ ] **Restyled screens.**
  - Home: a large "left to spend", the income line, upcoming bills and goals.
  - One expense form: amount first, merchant optional, category chips.
  - History: grouped by day, with search.
  - Bills & Cards, Insights, Settings and onboarding.
  - The remaining sheets and the Home Screen widgets.
- *Done when:*
  - text follows the phone's text-size setting
  - every icon-only button has an accessibility label
  - no screen sets fonts or colours outside the kit
  - every screen works in light mode, dark mode and Arabic

---

## 7. Build order & timeline

Re-planned on 2026-11-18 (D34), because no 2.4 code had landed by then. The work is 85 small steps in [BUILD_ORDER.md](BUILD_ORDER.md) (92 until D36 and D37 removed seven). This section keeps the phase order and the dates.

| Target (2026) | Phase or milestone |
|---|---|
| Nov 19 | 0 Groundwork, 1 Data model |
| Nov 21 | 2 Fixes and shared building blocks. Featuring nomination submitted in App Store Connect. |
| Nov 24 | 3 Design kit and core screens. **Checkpoint.** |
| Nov 25 | 4 Income |
| Nov 28 | 5 Bills & Cards (the riskiest sync work), then **TestFlight 1** for two-device testing |
| Nov 30 | 6 Free tier and first run. **Checkpoint.** |
| Dec 1 | 7 Everyday tools |
| Dec 3 | 8 Fast logging, with 10 Polish alongside (9 was dropped, D37) |
| **Fri Dec 4** | 11 Languages and rename. **Code freeze**: anything not solid moves to 2.5 (D9). |
| **Mon Dec 7** | 12 Release prep. **Submit 2.4**, leaving room for one rejection before the holiday review slowdown. |
| by Dec 11 | Submit the In-App Event "New Year Budget Reset" (runs Dec 28 – Jan 15). |
| Late Dec – Jan | Launch push (§12). |

- **Pace.** None of the 85 steps had landed by Nov 22, so freezing on Dec 4 needs about 6–7 a day. At 4–5 a day, use the fallback: freeze Dec 11 and submit Dec 14, which still leaves two weeks before Dec 28.
- **Checkpoints.** Being more than a day behind on Nov 24 or Nov 30 means choosing between the fallback dates and cutting from the slip order in BUILD_ORDER.md.

---

## 8. Naming

**Criteria**
1. **No exact or near match in App Store search** in the US, UK, UAE, Pakistan, India, Australia and Canada.
2. **Short.** The title is 30 characters and ": Expense Tracker" takes 17, so the name must be ≤ 13 characters, ideally ≤ 9.
3. **Siri recognizes it reliably.** Easy to say, not a common dictionary word Siri mishears, and natural inside "log an expense in *Name*".
4. **Works in Arabic and German:** no awkward meaning, pronounceable.
5. **Domain and trademark available.**
6. **Fits the positioning.** Hints at cards, cash or money left is a plus. Avoid "-wise" and "-ly" patterns, which are crowded.

**Process:** Claude proposes 10–15 candidates and pre-checks them against App Store search. Ahmad checks AppTweak, domain and trademark. Pick one by **Nov 21** (Q1).

Already taken or crowded (avoid): CardCycle, Leftly, SpendLoop, Duely, Statement Day, Tallyo. Clear in US search on Oct 24 (verify again): Cashline, Pocketline.

---

## 9. ASO & metadata

### 9.1 Which listing serves which store
Each listing has its own 30-character title, 30-character subtitle and 100-character keyword field. Verify this mapping in App Store Connect.

| Listing | Stores it serves | Notes |
|---|---|---|
| English (U.S.) | US | |
| Spanish (Mexico) | US (second keyword field), Mexico | **Optional (D36).** No Spanish translation in 2.4. If used, it holds extra English keywords for the US store. Many apps do this; Apple doesn't endorse it. |
| English (U.K.) | **UK, India, Pakistan, UAE** (shown as en-GB in AppTweak) | One keyword field must serve all four |
| English (Australia) | Australia | Easiest English market (low difficulty) |
| English (Canada) | Canada | About as hard as the US |
| Arabic | Saudi Arabia, UAE | In Saudi, people search in Arabic |
| German | Germany (+ AT/CH) | |

### 9.2 Drafts (finalize after naming and the final keyword pass)
Character counts were checked on Oct 24. Keyword fields don't repeat title or subtitle words.

| Listing | Title | Subtitle | Keyword field |
|---|---|---|---|
| en-US | *Name*: Expense Tracker | Bills, Budget & Card Due Dates (30) | `organizer,reminder,subscription,money,manager,credit,debt,payoff,spending,planner,finance,cash,daily` (100) |
| en-GB | *Name*: Expense Tracker | Budget Planner & Money Manager (30) | `bill,organiser,reminder,expenses,spending,daily,subscription,savings,card,credit,finance,debt,cash` (98) |
| en-AU | *Name*: Budget Planner | Expense, Bill & Money Tracker (29) | `savings,manager,spending,expenses,finance,card,credit,cash,daily,organiser,reminder,monthly,income` (98) |
| en-CA | *Name*: Expense Tracker | Budget Planner, Bill Organizer (30) | `money,manager,spending,savings,card,credit,debt,reminder,monthly,finance,expenses,subscription` (94) |
| ar | *Name*: تتبع المصاريف (draft) | built around ميزانية / فواتير | themes: مصاريف, ميزانية, فواتير, ادخار, مدير المال, بطاقة ائتمان. Native review required. |
| de | *Name*: Ausgaben Tracker (draft) | built around Haushaltsbuch / Budget Planer | themes: Kassenbuch (41/d0), Fixkosten (30/d10), Rechnungen (27/d5), Finanzplaner, Kreditkarte. Native review required. |
| es-MX (optional, D36) | English | English | Extra English keywords for the US store, not repeating en-US words. Chosen in the final keyword pass. |

Reasoning behind these choices:
- **en-US:** credit-card terms only belong here. Bill organizer/tracker/reminder are high volume with difficulty ~0.
- **en-GB:** "money manager" is strong in all four stores (UK 45, India 54, Pakistan 41, UAE 49). "Expenses" in the UK is 45/d0, and "organiser" is the British spelling.
- **Credit cards in en-GB, en-AU and en-CA** appear in the keyword field only. "Credit card" searches in those stores mean banks or paying bills.
- **Privacy terms never go in metadata.** They have no search volume.
- **Keywords that now depend on a 2.4 feature (D15, D19, D20):** `subscription` (Subscriptions view), `savings` (savings goals), `debt` / `payoff` (card payoff helper), `income` (income tracking). If one of those features slips to 2.5, take its word out before submitting.
- **What replaced `receipt` / `scanner` (D37, 2026-11-22).** These are drafts for the final keyword pass, with Appendix A data where it exists:
  - en-US: `finance` (finance tracker 44), `cash` and `daily` (cash tracker and daily expense tracker, both 26/d0)
  - en-GB: `finance`, `debt` (UK debt tracker 27) and `cash`
  - en-AU: `monthly` and `income` (no Australian data for either)
  - en-CA: `subscription` (high volume in the US and UK; no Canadian data)

### 9.3 Other listing fields
- **Description:** lead with the four pillars. Spell out what's free and what's Pro, plus the privacy statement. Update the old "logging requires Pro" wording.
- **Promotional text** (editable without review): seasonal hooks, e.g. "New Year budget reset".
- **What's New:** a real changelog every release.
- **Later:** Custom Product Pages tied to keywords (e.g. a "card due dates" page for US card terms). Product Page Optimization tests once traffic allows.

---

## 10. Screenshots & icon

**Screenshots** (one set per listing, 6–8 each). The first three appear in search results:
1. **"Budget privately. No bank login."** Home with a big "left to spend", plus a badge row: Face ID lock · No bank login · No account · Data Not Collected.
2. **"Never miss a card due date."** Cards with a due-date notification and the *Paid* state.
3. **"Log by voice."** A Siri request ("log 1,500 at McDonald's") or the Control Center button.
4. Bills, subscriptions & upcoming payments.
5. **"See when your card is paid off."** The payoff plan with its date and interest.
6. Lock Screen & Home Screen widgets.
7. Insights, income vs spending, and savings goals.
8. 49 currencies · English / العربية / Deutsch.

Rules:
- **Demo data only,** never personal data. Use a currency matching the listing: USD, AUD, CAD, SAR (Arabic), EUR (German). The en-GB set is shared by the UK, Pakistan, India and the UAE, so pick its currency deliberately (Q3).
- **Large, readable UI crops.** Captions carry keywords, since screenshot text is reportedly read for search since mid-2025.

**Icon:**
- Currency-neutral (no "$").
- Distinctive at small size.
- Matches the app's monochrome style.
- Hints at cards or money left.
- A/B test it later via Product Page Optimization (the alternate icon has to ship in the binary).

---

## 11. App Review & release checklist

**iCloud and the data model**
- [ ] **Deploy the CloudKit schema to Production** (new models and fields) once Phase 1 of BUILD_ORDER is done, **before TestFlight 1**: TestFlight builds sync against Production. Deploy again if a later step adds a field.
- [ ] Every new model follows the CloudKit rules: defaults on all properties, optional relationships, no `@Attribute(.unique)`.
- [ ] New models are added to **both** schema lists: [SpendSnapApp.swift](../SpendSnap/SpendSnapApp.swift) and [WidgetModelContainer.swift](../SpendWiseWidgets/WidgetModelContainer.swift).
- [ ] Shared files the widget target needs (intents, entities, models) are added to the widget **membershipExceptions** in `project.pbxproj`.
- [ ] Every mutation calls `WidgetRefresh.reloadAll()` after `save()`. New hand-cached screens observe `.spendWiseDidDeleteAllData`.

**Store and review**
- [ ] Lifetime product created and approved in App Store Connect. Subscription and product display names renamed.
- [ ] `NSFaceIDUsageDescription` is present for the app lock. No camera usage string is needed (D37).
- [ ] Privacy label is still "Data Not Collected" and the privacy manifest is up to date.
- [ ] **App Review notes:** what's free vs Pro, how to reach the paywall, the sandbox path, why Face ID is used, and how to try Siri and Control Center.
- [ ] The paywall shows price, period, trial terms, Restore, and Terms/Privacy links. Lifetime is labelled as a one-time purchase.

**TestFlight matrix (1–2 weeks)**

| Scenario | Covered |
|---|---|
| Two devices on the same iCloud account (sync, no duplicate categories or recurring expenses, mark-as-paid merge, savings contributions merge) | [ ] |
| A 2.3 device and a 2.4 device on one iCloud account: 2.3 doesn't crash on income, rules or payments and doesn't show them; editing a card on 2.3 keeps its 2.4 fields (`stableID`, `last4`, payoff values); cards and categories created on 2.3 get a `stableID` on 2.4 after a foreground | [ ] |
| iOS 17 (no Control Center control), iOS 18, iOS 26 (snippets), iOS 27 (new Siri) | [ ] |
| Fresh install vs upgrade from 2.3 with existing data (every card and category gets its own id; the latest month's budget becomes the every-month default) | [ ] |
| Free user vs subscriber vs lifetime vs lapsed subscriber | [ ] |
| English, Arabic (RTL), German | [ ] |
| Notifications: due, statement, bills, reminders, and the 64-pending limit | [ ] |
| Income: adding income changes no spending total, budget bar, card cycle or widget figure | [ ] |
| App lock: cold launch, return from background, cancelled check, device with no passcode | [ ] |
| Card payoff: the §6.3 worked example, a zero rate, and a payment too small to clear | [ ] |
| Widgets work for a free user, a subscriber, a lifetime owner and a lapsed subscriber | [ ] |

---

## 12. Launch & growth

**In the App Store (free)**
- In-App Event **"New Year Budget Reset"** (Dec 28 – Jan 15). Events appear in search results.
- **Featuring nomination** for 2.4. Angles: privacy, Siri / App Intents, Arabic support.
- The review prompt (§6.1) builds rating velocity. DaTrack reached ~790 ratings in each of the US and UK in 7 months.

**Outside the App Store (cheap first)**
- **Reddit:** r/iosapps, r/AppHookup (Lifetime launch discount), r/budget. Also Product Hunt and Indie Hackers.
- **Gulf expat communities** (Facebook / WhatsApp groups) for the Arabic and English launch.
- **Short videos** explaining "statement date vs due date", a real point of confusion, with the app as the answer.
- **A free statement / due-date calculator** on ahmadtariq.co with a Smart App Banner and campaign link.
- **Cross-promotion** from Circa. **Offer codes** for creators and newsletters.

**Paid**
- **Apple Search Ads:** no US spend until conversion is proven. US finance runs ~$3.80 per tap and ~$7 per install, versus ~$17 first-year net per payer. Use it for keyword popularity data. Small tests in the UAE and Pakistan after 2.4.

**Tracking:** a campaign link (`pt` / `ct`) per channel so App Store Connect attributes downloads.

---

## 13. Measurement

Built-in and private (no SDKs, D7). Review every **Monday**.
- **App Store Connect → App Analytics:** impressions and page views by **source** (Search / Browse / Web / App referrer) and by **country**. Also conversion rate, first-time downloads, sessions, retention (opt-in users), crashes, campaign links.
- **App Store Connect → Subscriptions:** trial starts, trial → paid, renewals, refunds, lifetime purchases.
- **Ratings** count and average per country.
- **Keyword ranks:** spot-check the §9 terms in AppTweak (until the trial ends Oct 29), then via Apple Search Ads popularity and manual search.

---

## 14. Risks

| Risk | Mitigation |
|---|---|
| The big release slips past the holiday window | Riskiest work first (§7). Hard freeze Dec 4. Slip rule (D9). |
| Duplicate recurring expenses across devices | Deterministic `recurrenceKey` + reconciler. Two-device TestFlight case. |
| CloudKit Production schema not deployed | Checklist item in §11. Sync breaks for live users without it. |
| Notification limit (64 pending) | Schedule only the next occurrence. Priority order. Reschedule on foreground. |
| Siri mishears the new name | Naming criterion 3. Test phrases on devices before locking the name. |
| Arabic RTL layout bugs / weak translations | Dedicated RTL QA pass. Native reviewers. |
| App Review rejection (paywall clarity, Face ID string, keyword-stuffed titles) | §11 checklist. Keep titles natural. Detailed review notes. |
| No 2.4 code had landed by Nov 22, so finishing 85 steps by Dec 4 needs about 6–7 a day | Riskiest sync work before the free tier (§7). Checkpoints on Nov 24 and Nov 30. Slip order in BUILD_ORDER.md. Fallback: freeze Dec 11 and submit Dec 14, still two weeks before Dec 28. |
| Income leaks into spending totals | Low since D27: income is a separate model, so no spending total reads it. The TestFlight case in §11 stays. |
| A keyword promises a feature that slipped | Re-check the keyword fields against shipped features at code freeze (§9.2). |
| Upgrading from 2.3 may give every existing card and category the same `id` | A one-time fix gives any shared id a fresh value (BUILD_ORDER step 1.1). Upgrade case in §11. |

---

## 15. Open questions

| # | Question | Owner | Due |
|---|---|---|---|
| Q1 | Final app name | Ahmad (Claude shortlists) | **Nov 21** (overdue; was Nov 13) |
| Q2 | Raise Yearly in US/UK/AU/CA? Lower local prices in PK/IN? | Ahmad | Nov 27, before `sw_lifetime` is created in App Store Connect |
| Q3 | Currency for the shared en-GB screenshot set (GBP vs neutral/multi) | Ahmad | screenshot production |
| Q4 | Who reviews the Arabic and German translations | Ahmad | Nov 23 |
| ~~Q5~~ | ~~Lock Screen widgets: Pro or Free?~~ **Resolved by D21:** all widgets are free. | Ahmad | done Nov 10 |
| ~~Q6~~ | ~~Spanish keyword set~~ **Resolved by D36:** Spanish is dropped from 2.4. | Claude | done Nov 22 |
| ~~Q7~~ | ~~Savings goals: one free, or fully free?~~ **Resolved by D24:** one goal free, unlimited in Pro. | Ahmad | done Nov 11 |
| ~~Q8~~ | ~~What can a free user do with cards?~~ **Resolved by D35:** add them as payment methods; cycles, alerts, mark-as-paid and payoff are Pro. | Ahmad | done Nov 18 |
| Q9 | Free users with a card see due dates in the Credit Cards and "next card due" widgets, which are free (D21). Keep that as a teaser (recommended), or hide due dates there for free users? Hiding them means sharing Pro status with the widget process. | Ahmad | Nov 28, before BUILD_ORDER step 6.1 |

---

## 16. Out of scope for 2.4 (candidates for 2.5+)
- In-app quick-type bar ("coffee 4.50"). It reuses the 2.4 parser.
- Payoff across several cards (which to pay first). Rewards / cashback per card.
- Shared or family books, Apple Watch, iPad.
- **Moved into 2.4 on 2026-11-10:** savings goals (D19) and the card payoff helper (D20, the first slice of the debt payoff planner).
- **First to move to 2.5 if we fall behind** (the slip order in BUILD_ORDER.md): Siri confirmation buttons, the pickers and info sheets restyle, card payoff, CSV export.
- **Dropped on 2026-11-22:** Spanish (D36), until there is a keyword source for it, and receipt scanning (D37), unless users ask for it.
- **Not planned (privacy decisions D5–D7):** Apple Pay auto-logging (re-confirmed in D22), SMS / bank-notification logging, cloud AI.

---

## Appendix A — Keyword research (AppTweak, iPhone, 2026-10-24)

Volume is 0–100 (5 = AppTweak's floor, essentially no searches). d = difficulty. Context apps: Tappy (round 1), DaTrack (round 2), CardStack (round 3).

**US (en-US):**
- **Core:** budget app 64/d20 · money manager 50/d10 · expense tracker 49/d10 · receipt scanner 49/d21 · money tracker 45/d11 · finance tracker 44/d20 · spending tracker 42/d20 · budgeting app 41/d20 · budget tracker 40/d20 · personal finance 38/d38 · spending 37 · expense 36/d0 · monthly budget 35 · budget 35 · budget planner 30/d11 · expense manager 30/d0 · simple budget 27 · cash tracker 26/d0 · daily expense tracker 26/d0
- **Bills, cards and debt:** bill organizer **53/d0** · bill tracker **45/d0** · subscription tracker **45/d0** · bill pay 40/d25 · debt 36/d6 · debt tracker 34/d0 · card manager **34/d0** · payment tracker 34/d0 · bill reminder 31/d0 · credit card payoff 28/d12 · debt payoff 27/d0 · bills 26/d4 · credit card manager 25/d9 · credit card tracker 21/d0 · credit card 53/d50 (bank intent)
- **At the floor:** statement date, billing cycle, due date reminder, credit card due date / payment reminder / bill reminder, and every privacy phrase (private / offline / manual / secure budget, budget without bank, no-account).

**UK (en-GB):**
- budget planner 55/d31 · budget 50/d20 · budget tracker 48/d21 · money manager 45/d9 · expenses **45/d0** · expense tracker 44/d12 (DaTrack #1) · money tracker 41/d20 · bill tracker 40/d14 · bills 40 · receipt scanner **40/d0** · spending tracker 39/d20 · subscription tracker 39/d9 · finance tracker 38 · savings tracker 38 · budget app 35 · bill organiser 31 · money planner 29 · debt tracker 27 · debt 27
- Credit-card terms at the floor. "Credit card" autocompletes to banks and bad-credit cards.

**India (en-GB):**
- money manager 54/d11 · expense tracker 53/d8 · expense manager 47/d0 · money tracker 43/d2 · budget tracker 40/d0 · budget 39 · spending tracker 38/d6 · hisab kitab 38/d0 · expense 37 · budget planner 36/d10 · daily expense tracker 36 · finance tracker 34 · personal finance 26
- Credit-card searches are bank or bill-payment intent: credit card 51, credit card payment 35, to bank transfer 33.

**Pakistan (en-GB):**
- khata 46/d42 · money manager 41/d31 · expense tracker 33/d10 · expense manager 30 · expense 29. Most other terms at the floor (small store).

**UAE (en-GB + Arabic):**
- money manager 49/d13 · budget 48/d19 · expense tracker 40/d13 · مصاريف 33/d3 · money tracker 32 · expense manager 31 · budget planner 29 · daily expense tracker 25
- "Credit card" 37 is bank names.

**Saudi Arabia (Arabic):**
- budget 56/d26 · مصاريف 53/d15 · money manager 42/d3 · ميزانية 37/d24 · ادخار 36/d39 · فواتير 29/d0 · expense manager 21. English "expense tracker" is only 5.
- بطاقة (card) autocompletes to loyalty and prepaid brands.

**Australia (en-AU):**
- budget planner 54/d16 · budget 54/d16 · money 53 · money manager 46/d11 · money tracker 40/d8 · savings tracker 40/d4 · expense tracker 38/d5 · budget tracker 38/d8 · bill tracker 38/d2 · budget app 37 · finance tracker 37 · receipt scanner 37 · spending tracker 33/d5 · expenses 31/d4
- Subscription and credit-card terms at the floor.

**Canada (en-CA):**
- budget planner 57/d39 · budget 56/d41 · budget tracker 50/d30 · money manager 50/d23 · spending tracker 48/d25 · expense tracker 44/d19 · receipt scanner 41/d29 · money tracker 40/d18 · savings tracker 38/d12 · budget app 37/d41 · bill tracker 36/d17 · expenses 34/d7 · monthly budget 30 · receipt tracker 30/d5 · bill organizer 29/d4 · expense manager 23/d6

**Germany (German):**
- finanzen 56/d52 · ausgaben tracker 52/d26 · finanzplaner 50/d36 · kreditkarte 49/d71 · sparen 48 · budget 46 · budget planer 43/d32 · kassenbuch 41/d0 · ausgaben 40/d29 · haushaltsbuch 34/d29 · fixkosten 30/d10 · rechnungen 27/d5

## Appendix B — Competitors & benchmarks

| App | Signal | Hook | Pricing | Languages |
|---|---|---|---|---|
| Tappy (Jun 2026) | #12 top-grossing finance app in India, #17 in Pakistan; 535 India ratings | Log without opening the app (Siri, Back Tap, widgets); "free forever" core | ₹79 / ₹499 / ₹1,999 | EN |
| DaTrack (Mar 2026) | Top-50 grossing in UK, Australia, Canada; ~790 ratings each in US and UK | Per-store titles; AI typed entry + receipts | £4.99/mo, £29.99/yr, £69.99–99.99 lifetime | 8 |
| Fleur (2022) | Charts in US, UK, Australia, Canada, Germany | Bills in every subtitle; per-store titles | A$9.99/mo, A$49.99–59.99/yr | 28 |
| Kharcha Book (2022) | #6 top-grossing in Pakistan | Shared khata books | Rs 300/mo, Rs 1,000/yr | EN |
| TapSheet (Jan 2026) | #14 top-grossing in Pakistan, #10 in Canada | Onboarding quiz → plan → hard paywall | $5.99/wk, $9.99/mo, $29.99/yr | EN |
| Quanto (Jan 2026) | UAE #29, India #18 top-grossing | AI entry (third-party AI), Control Center, Siri | $2.99/mo, $24.99/yr, $59.99 lifetime | 13 |
| Card trackers (CardStack, MyCards, Cardsy, DueDate, CardBee…) | All < 60 ratings | Card-only | — | — |
| CardPointers / MaxRewards | 10k / 17k US ratings | Rewards optimisation (different job) | — | — |
| Bills Organizer & Reminder | 25k US ratings | Bills | — | — |

**Per-store title examples:**
- DaTrack: US/UK "Expense Tracker – DaTrack"; AU/CA "Budget Planner: DaTrack"
- Fleur: 4 variants
- Fudget: "Monthly Budget Planner" / "Budget Planner" / "Budget Tracker"

## Appendix C — Sources
- RevenueCat, State of Subscription Apps 2026: https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026
- Adapty, App Store conversion benchmarks: https://adapty.io/blog/app-store-conversion-rate/
- SplitMetrics, Apple Search Ads benchmarks: https://www.splitmetrics.com/blog/apple-search-ads
- Adapty, Custom Product Pages: https://adapty.io/blog/custom-product-pages-app-store/
- Apple Developer Forums, App Shortcut phrase limits: https://developer.apple.com/forums/thread/779109 · https://developer.apple.com/forums/thread/782605
- WWDC25 interactive snippets / App Intents: https://developer.apple.com/videos/play/wwdc2025/281 · https://developer.apple.com/videos/play/wwdc2025/275
- Siri AI & App Intents in iOS 27: https://www.cultofmac.com/news/siri-ai-third-party-apps-ios-27
- Competitor listings: Tappy https://apps.apple.com/in/app/id6777520962 · DaTrack https://apps.apple.com/gb/app/id6760328162 · Fleur https://apps.apple.com/au/app/id1621020173 · Quanto https://apps.apple.com/us/app/id6749017099 · Kharcha Book https://apps.apple.com/pk/app/id1608360032 · TapSheet https://apps.apple.com/us/app/id6757964945
- AppTweak keyword data: Ahmad's AppTweak workspace (trial), pulled 2026-10-24.
