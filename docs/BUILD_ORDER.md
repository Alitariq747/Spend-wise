# Build Order — v2.4 relaunch

> [MASTER_PLAN.md](MASTER_PLAN.md) says **what** ships in 2.4. This file says **in what order** we build it, as small numbered steps done one at a time.
> Created 2026-11-18. It replaces the week-by-week table in MASTER_PLAN §7, whose dates are stale: no 2.4 code had landed by Nov 18.
> On 2026-11-22, D36 and D37 dropped Spanish and receipt scanning: step 11.6 and all of Phase 9 are gone, leaving 85 steps. On 2026-11-24, step 1.4 (CloudKit schema in Development) was added, making 86, and step 11.7 (month labels on the Islamic calendar), making 87. On 2026-11-25, step 2.5a (one budget row per month) was added, making 88.
> Tick a step when it lands. The rules for step size and workflow are in [CLAUDE.md → Working in steps](../CLAUDE.md#working-in-steps).

**Contents:** How a step works · Status board · Decisions this order builds on · Phases 0–12 · Ahmad's track · Slip order · Schedule check

---

## How a step works

1. Take the first unticked step, or a ⇄ step in a separate session.
2. Claude posts a short plan in chat (files, approach, estimated size, how it will be checked). Ahmad says go.
3. Claude builds it. A step adds or changes about 150 lines of Swift at most, never more than 200. Anything bigger is split into `3.5a`, `3.5b`… and written into this file before coding starts.
4. Both targets build, and the step's **Done when** line is checked in the simulator or with a scratch harness.
5. Tick the box here. When a feature's last step lands, tick its box in MASTER_PLAN §6 too. Claude says the step is ready to commit, and Ahmad commits it in Xcode. He also sets the version and build number there.

Sizes are estimates of added or changed Swift lines. Deletions, String Catalog data, asset JSON, `project.pbxproj` and docs don't count.

**Tags**
- **⇄** needs only the steps it names, so it can run in a parallel session.
- **Pro** is gated with `requirePro` (built in 2.8).
- **✂** is on the slip list.

---

## Status board

| Phase | Steps | Target finish | Done |
|---|---|---|---|
| 0 Groundwork | 3 | Nov 19 | 3 |
| 1 Data model | 4 | Nov 19 | 4 |
| 2 Fixes and shared building blocks | 9 | Nov 21 | 8 |
| 3 Design kit and core screens | 12 | Nov 24 | 0 |
| 4 Income | 4 | Nov 25 | 0 |
| 5 Bills & Cards | 14 | Nov 28 | 0 |
| 6 Free tier and first run | 11 | Nov 30 | 0 |
| 7 Everyday tools | 5 | Dec 1 | 0 |
| 8 Fast logging | 11 | Dec 3 | 0 |
| 9 Receipt scanning: dropped (D37) | 0 | — | — |
| 10 Polish | 4 | Dec 4 | 0 |
| 11 Languages and rename | 7 | Dec 4 | 0 |
| 12 Release prep | 4 | Dec 7 | 0 |
| **Total** | **88** | Freeze Dec 4, submit Dec 7 | **15** |

Phases run in order: Bills & Cards (the riskiest sync work) comes before the free tier, as MASTER_PLAN §7 decided. Phase 10 can run alongside 8 in a parallel session.

---

## Decisions this order builds on

All of these are recorded in MASTER_PLAN §3. The ones added for this build:
- **D25** A card shows its last closed statement until that statement's due date.
- **D26** The monthly budget gets an "every month" default. A month's own budget overrides it.
- **D27** Income is its own model, so 2.3 devices on the same iCloud never count it as spending.
- **D28** Deleting a category moves its expenses to "Other".
- **D29** Five tabs: Cards becomes "Bills & Cards", goals live on Home, and the + button offers Expense and Income.
- **D30** The design kit comes before any new screen. Existing screens are restyled in the step where they gain features.
- **D31** Merchant memory uses the merchant's most recent expense, then a bundled list. No new model.
- **D32** Income sources are a fixed list: Salary, Business, Freelance, Gift, Other.
- **D33** Card-alert lead days are set per device.
- **D35** Free users can add cards as payment methods. Cycles, alerts, mark-as-paid and payoff are Pro.
- **D36** No Spanish in 2.4. The languages are English, Arabic and German.
- **D37** No receipt scanning in 2.4, so no camera permission and no Scan in the + menu.

**Still open:** **Q9**, whether the free card widgets show due dates to free users (MASTER_PLAN §15). It is needed before step 6.1.

---

## Phase 0 — Groundwork (nothing changes for users)

- [x] **0.1 Version number and dead code** · ~10 lines
  - Set `MARKETING_VERSION` to 2.4 for both targets (it is 1.0 today) and bump the build number. Ahmad does this himself in Xcode.
  - Delete the unused `ExpenseCard`, `CategoryMacroCard`, `TabPill` (with `InsightsTab` and its one `@State`), `CompactHeader`, `UnlockPro`, `UpgradeToPro`, `CurrencyUtil.format`, `format2`, `round2` and `idealToDate`.
  - Keep the unused `Settings.proUnlocked` and `iCloudSyncOn` fields: 2.3 devices still sync them, and removing them gains nothing.
  - *Done when:* both targets build and the app behaves exactly as before.
- [x] **0.2 One home for the app's name and links** · ~60 lines
  - Add an `AppInfo` type shared with the widget target. It holds:
    - the display name and Pro name
    - the App Store id and write-review URL
    - the support email
    - the terms and privacy URLs
  - Replace the 8 hard-coded "SpendWise" texts in onboarding, notifications, the paywall, Settings and widget descriptions.
  - Internal identifiers stay as they are: bundle IDs, `SpendWise://`, the CloudKit container and the App Group.
  - *Done when:* "SpendWise" appears in Swift code only in `AppInfo` and internal identifiers, so the rename (11.6) is a one-line change.
- [x] **0.3 String Catalogs** · ~10 lines
  - Add `Localizable.xcstrings` to the app and widget folders, and add `ar` and `de` to the project's known regions. Extraction is already on (`SWIFT_EMIT_LOC_STRINGS`).
  - `xcodebuild` doesn't write strings back, so the catalogs are filled with `xcstringstool sync` from the build's `.stringsdata` (command in CLAUDE.md → Strings and languages).
  - *Done when:* both catalogs list their target's strings and both targets build. From here on, every new user-facing string goes through a catalog.

## Phase 1 — Data model (one pass)

Every new model and field lands here, before any feature uses it. Each one:
- follows the CloudKit rules in CLAUDE.md
- is added to both schema lists
- if it is a new model file, is added to the widget target's `membershipExceptions`

Relationships are optional and have inverses, because CloudKit requires both.

- [x] **1.1 New fields on existing models** · ~110 lines
  - `CreditCard` gains `stableID`, `last4`, `amountOwed`, `yearlyRate` and `plannedPayment`.
  - `CategoryEntity` gains `stableID` and `systemKey`: empty for the user's own categories, and `food`, `other`… for seeded ones.
  - `Expense` gains `recurrenceKey`.
  - `Settings` gains `defaultMonthlyBudget`, `defaultPaymentMethodRaw` and `defaultCardID`, and `SettingsReconciler` merges them.
  - `stableID` is `UUID?`, `nil` by default, set in `init`. It is not called `id`, because that would replace SwiftData's identity in `ForEach`. A non-optional default would also give every migrated row, and every row synced from a 2.3 device, the same value.
  - `IdentityBackfill` gives a fresh id to any card or category whose `stableID` is `nil`. It runs at launch and on every foreground, because 2.3 devices keep creating rows without one. It never changes an id that is set. Readers must handle `nil` until it runs.
  - *Done when:* a 2.3 install with real data upgrades with every expense, budget, card and category intact, and every card and category has a distinct `stableID`.
- [x] **1.2 Income, recurring rules, statement payments** · ~120 lines
  - Enum-backed fields are stored as raw `String`s, so a value from a newer version reads as a fallback instead of failing to decode. The raw values are permanent once deployed.
  - `Income`: `amount`, `date`, `monthKey` (set in `init`), `sourceRaw` (`salary`, `business`, `freelance`, `gift`, `other`; D32), `note`, `recurrenceKey`.
  - `RecurringRule` holds:
    - `stableID: UUID?`, set in `init`. Recurrence keys are built from it. A rule with no id generates nothing, so two rules can never share keys and have the 5.9 cleanup delete each other's entries.
    - `name`, `amount`, and `kindRaw` (`expense`, `income`)
    - `frequencyRaw` (`weekly`, `biweekly`, `monthly`, `yearly`) and `startDate`, which also fixes the day of the month
    - optional `category` and `card`, `paymentMethodRaw`, `incomeSourceRaw`
    - `isSubscription`, `reminderDays: Int?` (`nil` means no reminder, `0` means on the day), `isActive`, `createdAt`
    - `generatedThrough: Date?`: how far entries have been created, so a deleted entry stays deleted and a resumed rule skips the paused months
  - Deleting a card or category clears its link on a rule (`.nullify` inverses on both).
  - `StatementPayment`: `card` (deleting a card deletes its payments), `statementKey` (the closing date as a POSIX Gregorian `yyyy-MM-dd` string, so every device groups it the same), `amountPaid`, `paidInFull`, `paidAt`.
  - All three go into both schema lists and the widget's `membershipExceptions`. The lists must match: the widget opens the same file, and a list missing a model could migrate that model's table away.
  - *Done when:* both targets build, the schema lists match, and a 2.3 store upgrades straight to 1.2 with all data intact. A debug check shows that deleting a card and a category clears a rule's links and deletes the card's payment.
- [x] **1.3 Savings goals, and delete-all for every new model** · ~90 lines
  - `SavingsGoal`: name, emoji, target, optional target date, created at.
  - `GoalContribution`: amount (negative for a withdrawal), date, goal.
  - "Delete all data" also removes the five new models, deleting children before parents.
  - *Done when:* delete-all leaves no rows of any model, and the app shows its empty state without crashing.
- [x] **1.4 CloudKit schema in Development** · ~40 lines · needs 1.3
  - CloudKit's Development database only gains a field when a record carrying it syncs. Empty optionals (`defaultCardID`) and models with no rows yet (everything from 1.2 and 1.3) would be missing, so deploying them to Production would leave them out.
  - A DEBUG-only launch argument, `-initCloudKitSchema`, calls Apple's `initializeCloudKitSchema()` on an `NSPersistentCloudKitContainer` built from the same SwiftData models. It uploads placeholder records for every model and field, then deletes them. It only works against Development.
  - With the argument, the app does not boot normally: it never opens the real store or starts sync. It uses a throwaway store in the temp folder, shows the result and stops. Without the argument nothing changes, and release builds don't contain it.
  - Ahmad signs the simulator into iCloud. Claude runs the app with the argument.
  - Run it again whenever a later step adds a field or model, before deploying again.
  - *Done when:* the CloudKit console's Development schema shows every model from both schema lists, with every field, including `defaultCardID` and the 1.2 and 1.3 models.

**Milestone: CloudKit schema to Production (12.3).** Once Phase 1 is done and checked, including 1.4, Ahmad deploys the schema. It must happen before TestFlight 1, because TestFlight builds sync against Production. After deploying, fields can be added but never renamed, removed or retyped.

## Phase 2 — Fixes and shared building blocks

- [x] **2.1 One amount parser for every input** · ~100 lines · ⇄ needs 0.1
  - Follows the user's locale. Accepts `12.50`, `12,50`, `1,250.00`, `1.250,00`, Arabic-Indic and Persian digits, and a stray currency symbol.
  - Used by the expense, budget, category and card fields, which use three different parsers today.
  - *Done when:* a harness gives:
    - 12.5 for `12,50` in de_DE
    - 1250 for `1.250,00` in de_DE
    - 12.5 for `١٢٫٥٠` in ar_SA
    - 1500 for `1,500` in en_US

    Each field saves those values in the simulator.
- [x] **2.2 One money formatter: app screens** · ~110 lines
  - `Money.format(_:code:)` and a `MoneyText` view: the app's currency symbols, thousands separators, sensible decimals, and the user's numerals.
  - It replaces the 23 hand-built `"\(symbol)\(amount)"` strings.
  - *Done when:* every screen shows grouped amounts, such as `Rs 1,250` and `$12.50`, and an Arabic locale shows Arabic numerals.
- [x] **2.3 One money formatter: widgets** · ~50 lines
  - Share the formatter with the widget target. It replaces the widget strings, which glue the symbol to a raw number.
  - *Done when:* all three widgets show the same amounts as the app.
- [x] **2.4 Cards show the statement that is actually due** · ~100 lines · D25
  - The cycle helper also returns the last closed statement: its period, total and due date. The card tile and the Credit Cards widget show that bill until its due date passes, then the next one.
  - Card views fetch only that card's expenses for the dates shown. Today four views load every expense in the store.
  - *Done when:* with statement day 1 and due day 21:
    - from 1 to 21 Aug, the card shows July's total due 21 Aug
    - on 22 Aug, it moves to 21 Sep

    Checked with a harness, then in the simulator.
- [x] **2.5 The monthly budget carries over** · ~120 lines · D26
  - The budget sheet gets "This month / Every month":
    - Every month writes `Settings.defaultMonthlyBudget`.
    - This month writes a `Budget` row for that month only.
  - One `monthlyBudget(for:)` helper (the month's row, else the default) feeds Home, Insights and both budget widgets.
  - On upgrade, if no default is set, the latest month's budget becomes the default.
  - *Done when:* an "every month" budget saved in November shows in December untouched, and a "this month" change in December leaves November and January alone.
- [x] **2.5a One budget row per month, last edit wins** · ~60 lines · model change
  - Found in 2.5: CloudKit can't enforce one `Budget` row per month, so two devices saving the same month before they sync leave two rows. Today a month shows an arbitrary one, and the budget sheet can edit a different row from the one Home shows.
  - `Budget` and `CategoryMonthlyBudget` gain `updatedAt: Date? = nil`, set on create and on every edit. Optional on purpose: migrated rows and rows from 2.3 devices have no real time.
  - One rule picks a month's row everywhere: newest `updatedAt`, rows without one last, then the higher amount, then the `id`. `Budget.amount`, the budget sheet and the cleanup all use it, so the app and the widgets agree.
  - `BudgetReconciler` runs at launch and on every foreground: for each month with more than one `Budget` row it keeps the rule's pick and deletes the rest. "This month" does the same for its month when it saves.
  - Category budgets only get the field here. Reading and cleaning them up is in 3.9.
  - *Done when:*
    - with two rows for one month, the newer shows on Home, Insights and the widgets, and the older is gone after the next launch
    - a "this month" save sets `updatedAt` and leaves one row for that month
    - the upgrade test passes, and the schema upload shows `CD_updatedAt` on `CD_Budget` and `CD_CategoryMonthlyBudget`
- [x] **2.6 Reminders stop wiping other notifications** · ~50 lines
  - Changing the reminder level removes only the logging reminders, by identifier. Today it removes every pending notification.
  - This starts the one `NotificationScheduler` that the card and bill alerts (5.4, 5.5, 5.10) extend.
  - *Done when:* a test alert stays pending after the reminder level changes, checked by listing pending requests in a debug build.
- [x] **2.7 Small fixes** · ~50 lines
  - A category can be created without a budget, and its row then shows spending with no percentage.
  - Silver and platinum cards get dark text. White text on light metal is unreadable in the live screenshots. (Measured in 2.7: silver, gold and rose gold had white text; platinum was already dark. The text colour is now picked against both ends of the gradient.)
  - *Done when:* both work in the simulator, in light and dark mode.
- [ ] **2.8 One Pro check, plus Lifetime** · ~110 lines
  - `StoreKitManager.hasPro` is true for an active `sw1`/`sw2` or the Lifetime non-consumable `sw_lifetime`. It replaces `hasActiveSubscription`.
  - One `requirePro` helper refreshes entitlements if needed, then runs the action or shows `GoProSheet`. It replaces the three hand-written gates, with no change in behaviour yet.
  - Add Lifetime ($39.99) to `SpendWise Pro.storekit`, and fix the file's stale yearly price ($29.99, should be $19.99).
  - *Done when:*
    - monthly and yearly still unlock Pro
    - a Lifetime purchase made in Xcode's StoreKit transaction manager unlocks it
    - an expired subscription locks it again

## Phase 3 — Design kit and core screens (D30)

- [ ] **3.1 Design tokens** · ~90 lines
  - A colour set in the asset catalog, in light and dark: background, surface, stroke, primary and secondary text, one accent, and positive, warning and negative.
  - A type scale on the system text styles, so text follows the user's text size, plus a rounded style for large amounts.
  - Two corner radii and one spacing scale. Today there are 7 radii and 3 accent colours.
  - *Done when:* a SwiftUI preview (not shipped) shows every token in light and dark mode, at default and largest text size.
- [ ] **3.2 Components, part 1** · ~130 lines
  - Surface style, primary and secondary buttons, a sheet header with a labelled close button (replacing the three `Text("X")` buttons), a section header, and `MoneyText` sizes.
  - Every icon-only button gets an accessibility label. Today the whole app has 2.
  - *Done when:* previews show each component in light mode, dark mode and large text.
- [ ] **3.3 Components, part 2** · ~130 lines
  - A chip, a progress bar with warning and over states, an empty state, and a large amount field that uses the 2.1 parser.
  - *Done when:* previews show each component in light mode, dark mode, large text and Arabic (right to left).
- [ ] **3.4 Tab bar and the + button** · ~100 lines · D29
  - Restyle `CustomTabBar` with the tokens, and rename the Cards tab "Bills & Cards".
  - One floating + button serves Home and History. It opens the expense form, and becomes an Expense / Income menu once Income (4.1) exists.
  - The widget's `SpendWise://addExpense` link opens the form directly, instead of switching to History.
  - Check every tab with VoiceOver. In 2.6, an accessibility press on the Settings tab didn't switch to it, while the other tabs worked, so VoiceOver users may not be able to open Settings.
  - *Done when:* the tab bar and + look the same on every tab, and the widget's + opens the form.
- [ ] **3.5 Expense form, part 1: one form for add and edit** · ~150 lines
  - A new `ExpenseForm` built from the kit. The amount comes first and is large, the merchant is optional (capped at 40 characters as you type), then the date.
  - Add and edit both use it. Delete `AddExpenseSheet` and `ExpenseDetailSheet`, two 300-line copies today.
  - The merchant cap is the last part of MASTER_PLAN §6 "Small fixes" (2.7 did the other two), so tick that box when this step lands.
  - *Done when:* adding and editing work with or without a merchant, and an expense with no merchant shows its category name in lists.
- [ ] **3.6 Expense form, part 2: category and payment** · ~120 lines
  - Category chips that fit on screen without scrolling for the default set.
  - The payment method (cash or a card) is preselected from `Settings`. It is Cash until 6.7 adds the setting.
  - *Done when:* after typing an amount, an expense takes three taps to log.
- [ ] **3.7 Expense form, part 3: delete and errors** · ~80 lines
  - Edit mode deletes only after confirming. A failed save rolls back and tells the user. Today `try?` hides save errors.
  - *Done when:* delete asks first, and a save forced to fail leaves no half-saved expense.
- [ ] **3.8 Home, part 1: the headline** · ~120 lines
  - A large "left to spend", with spent and budget under it, a progress bar, and today's and this week's spending. The budget comes from 2.5.
  - *Done when:* Home reads at a glance in light and dark, over and under budget, and with no budget set.
- [ ] **3.9 Home, part 2: categories** · ~100 lines
  - Category rows built from the kit. A row without a budget shows spending only.
  - A line shows how much of the monthly budget isn't assigned to any category.
  - A category's month budget uses 2.5a's rule (newest `updatedAt`) when a month has more than one `CategoryMonthlyBudget` row, and the category edit sheet keeps one row per month when it saves.
  - *Done when:* with a 100,000 budget and 70,000 assigned to categories, Home shows 30,000 unassigned.
- [ ] **3.10 History, grouped by day** · ~130 lines
  - A section per day with that day's total. The whole row is tappable (today only the small "…" is). Add an empty state.
  - *Done when:* a month of 40 expenses reads as days with totals, and tapping anywhere on a row opens it.
- [ ] **3.11 Search in History** · ~50 lines · D17, free
  - `.searchable` over the month: merchant, category name and amount.
  - *Done when:* typing filters the list, clearing restores it, and the screen still clears its cache on `.spendWiseDidDeleteAllData`.
- [ ] **3.12 Settings, regrouped on the kit** · ~120 lines
  - Restyle Settings into Plan, Preferences, Security, Bills & alerts, Data, Shortcuts and General, so that later steps (5.5, 6.7, 7.2, 7.5, 8.10) add their rows in place.
  - *Done when:* every existing row still works in its new section.

## Phase 4 — Income (D27, D18, free)

- [ ] **4.1 Log income** · ~120 lines
  - The form gets an Expense / Income switch. Income has an amount, a date, source chips (D32) and an optional note.
  - The + button becomes a menu with Expense and Income.
  - *Done when:* income saves as an `Income` row and no spending number anywhere changes.
- [ ] **4.2 Income in History** · ~90 lines
  - Income rows sit among each day's expenses, marked as money in. Tap one to edit or delete it, and search finds them too.
  - Day totals stay spending only.
  - *Done when:* income appears on the right day, edits and deletes, and leaves the day totals unchanged.
- [ ] **4.3 Income on Home** · ~80 lines
  - A line under the headline shows money in, money out and net for the month. "Left to spend" stays budget minus spending.
  - The budget sheet shows this month's income as a hint.
  - *Done when:* adding income changes only the in and net figures.
- [ ] **4.4 Insights restyle, with income vs spending** · ~130 lines · Pro (gate lands in 6.1)
  - Insights cards built from the kit, a category legend with amounts and percentages, and a new income-vs-spending card.
  - *Done when:* the legend's amounts add up to the month's spending, and the new card matches Home's in and out figures.

## Phase 5 — Bills & Cards

- [ ] **5.1 Statement status** · ~100 lines · ⇄ needs 1.2, 2.4
  - For each card: the open cycle's spending, the last statement's total and due date, and a status of *Paid*, *Due in N days* or *Overdue*, read from `StatementPayment` rows.
  - *Done when:* a harness covers paid, partly paid, due today, overdue, and a statement day of 31 in February.
- [ ] **5.2 Card tiles and card detail on the kit** · ~120 lines
  - The tile shows the 5.1 status: neutral, warning within 3 days, red when overdue. Today the due pill is always red.
  - The card list uses each card's own identity (`ForEach(cards)`). Today it is keyed by name, so two cards with the same name clash.
  - Light cards (platinum, silver) need a visible edge in light mode: today they blend into the white background. Their text is fine since 2.7.
  - *Done when:* each status looks distinct in light and dark mode, and two cards with the same name both show.
- [ ] **5.3 Mark a statement as paid** · ~130 lines · Pro
  - On the card, mark a statement "Paid in full" or enter a partial amount.
  - There is one `StatementPayment` per card per statement. If two devices each create one, a reconciler modelled on `SettingsReconciler` keeps the one with the larger amount.
  - A partial payment adds the unpaid rest to the card's amount owed, which the payoff plan (5.14) uses.
  - *Done when:* paying shows *Paid*, and two simulators on one iCloud account that both mark the same statement end up with one record.
- [ ] **5.4 Card alerts** · ~140 lines · Pro
  - A due alert 3 days and 1 day before the due date (D33), plus "Statement closes tomorrow: Rs X this cycle".
  - Only the next occurrence per card is scheduled, and paid statements are skipped. Alerts are rescheduled on every foreground and after any change to a card or payment.
  - *Done when:* a card due in 3 days has a pending alert, and marking it paid removes the alert.
- [ ] **5.5 Alert settings and the 64-alert limit** · ~80 lines
  - Under Settings → Bills & alerts: alerts on or off, and the lead days. If notification permission is refused, the app explains how to turn it on.
  - The scheduler keeps fewer than 64 pending notifications (the iOS limit), in priority order: card dues, then bills, then logging reminders.
  - *Done when:* with enough cards and bills to pass 64, card alerts are kept and logging reminders are dropped first.
- [ ] **5.6 Recurring rules: the form** · ~140 lines · Pro
  - Create and edit a rule with:
    - name and amount
    - expense or income
    - frequency (weekly, every 2 weeks, monthly, yearly) and start date
    - category or income source
    - cash or card
    - the subscription flag and reminder days
  - *Done when:* a rule saves and edits, and invalid input can't be saved.
- [ ] **5.7 Bills list** · ~100 lines · Pro
  - A Bills section in Bills & Cards lists rules by next due date, each with pause and delete.
  - *Done when:* each rule shows its next date and amount, and a paused rule drops out of Upcoming.
- [ ] **5.8 Create recurring entries** · ~120 lines · date maths ⇄ needs 1.2
  - On launch and on every foreground, each active rule creates an expense or income for every occurrence after `generatedThrough` up to today, then moves `generatedThrough` forward. `recurrenceKey` is the rule's `stableID` plus the occurrence date. Because of `generatedThrough`, an entry the user deleted is not created again. Resuming a paused rule sets `generatedThrough` to today, so the paused months are skipped.
  - Date maths uses `MonthUtil.gregorian`. A day-31 rule falls on the last day of shorter months, and a 29 Feb rule falls on 28 Feb in other years.
  - *Done when:*
    - a harness covers monthly on the 31st, yearly on 29 Feb, and every 2 weeks
    - a rule that started months ago creates one entry per past occurrence, and none on the next launch
- [ ] **5.9 Recurring duplicate cleanup** · ~80 lines
  - Two devices offline at once can create the same occurrence. A reconciler removes entries that share a `recurrenceKey`, keeping the oldest. It runs on appear and whenever counts change.
  - *Done when:* a duplicate inserted in a debug build is removed on the next launch, and two simulators that both create an occurrence end up with one after sync.
- [ ] **5.10 Bill reminders** · ~70 lines · Pro
  - The scheduler adds each rule's next occurrence, at its lead time, below card alerts in priority.
  - *Done when:* a bill due in 2 days with a 2-day reminder has a pending alert, and pausing the rule removes it.
- [ ] **5.11 Upcoming on Home** · ~90 lines
  - An "Upcoming" section lists bills and card dues in the next 14 days, soonest first. Tapping an item opens it. Users with neither don't see the section.
  - *Done when:* a bill and a card both due this week appear in date order.
- [ ] **5.12 Subscriptions view** · ~100 lines · Pro, D15 · totals ⇄
  - Lists the rules flagged as subscriptions, with each one's next charge date.
  - Shows a monthly and a yearly total: weekly × 52 ÷ 12, every 2 weeks × 26 ÷ 12, yearly ÷ 12.
  - *Done when:* subscriptions of 5 a week, 10 a month and 120 a year show 41.67 a month and 500 a year.
- [ ] **5.13 Payoff maths** · ~60 lines · ⇄ needs nothing · ✂
  - A pure function that works month by month: add a month's interest, then subtract the payment. It returns the number of payments, the payoff date and the total interest, or "never" when the payment doesn't cover a month's interest.
  - *Done when:* a harness gives:
    - 13 payments and about 41,350 interest for 200,000 owed at 36% a year, paying 20,000 a month
    - "never" at 6,000 a month
    - 10 payments and no interest at a 0% rate
- [ ] **5.14 Payoff plan on the card** · ~130 lines · Pro, D20 · ✂
  - The card edit sheet gains amount owed, yearly rate (optional) and planned payment. The card detail shows a Payoff plan section that updates as the payment changes.
  - *Done when:* the 5.13 example shows the same numbers on screen.

**Milestone: TestFlight 1.** After Phase 5, the first internal build goes out for two-device sync testing (MASTER_PLAN §11).

## Phase 6 — Free tier and first run

- [ ] **6.1 Free logging, and Pro gates where they belong** · ~100 lines · D35, needs Q9
  - Remove the subscription gate from adding expenses (Home, History and the widget link) and from adding a card (D35).
  - Gate the Pro items from MASTER_PLAN §5 with `requirePro`: past months (the month picker's back arrow), Insights, and the card cycle view. Alerts, mark-as-paid and payoff are already gated in their own steps.
  - *Done when:* a fresh install with no purchase can log, edit and delete expenses and income and add a card, and every Pro entry point opens the paywall.
- [ ] **6.2 Paywall, part 1: plans** · ~130 lines
  - Monthly, Yearly and Lifetime. Yearly is preselected, with its per-month price and saving worked out from the live prices. Lifetime is labelled "one-time purchase".
  - *Done when:* all three plans buy and restore with the local StoreKit file, and at today's prices the badge reads "$1.67/mo · save 44%".
- [ ] **6.3 Paywall, part 2: what it says** · ~100 lines
  - Change the paywall's text:
    - List Pro features only. "Light and dark appearance" and the other free items go.
    - Add a "free forever" line and the trial timeline (today, day 12 reminder, day 14 billed).
    - Replace the top line, which today says logging needs Pro.
  - Price, period, trial terms, Restore, and the Terms and Privacy links stay (MASTER_PLAN §11).
  - *Done when:* nothing on the paywall presents a free feature as Pro.
- [ ] **6.4 Default categories** · ~110 lines
  - On first run, create the `Category` enum's categories plus "Other", each with its `systemKey`, guarded by `hasSeededDefaultCategories`. Existing users who already have categories get only "Other".
  - *Done when:* a fresh install can log its first expense with zero setup.
- [ ] **6.5 Category duplicate cleanup** · ~90 lines
  - Two devices can both create the defaults. A reconciler merges categories with the same `systemKey` into one, moving their expenses and budgets, and runs the same way `SettingsReconciler` does.
  - *Done when:* two fresh simulators on one iCloud account end up with one set of default categories.
- [ ] **6.6 Deleting a category keeps its expenses** · ~40 lines · D28
  - Move the expenses to Other before deleting, because the category-to-expenses relationship cascades. Other itself can't be deleted, and the warning text changes to match.
  - *Done when:* deleting a category with 5 expenses leaves those 5 expenses under Other.
- [ ] **6.7 Default payment method** · ~60 lines
  - A Settings row to choose Cash or one card. The expense form preselects it, and so does Siri (8.4).
  - *Done when:* choosing a card makes it the form's default, and deleting that card falls back to Cash.
- [ ] **6.8 Onboarding, part 1: intro** · ~120 lines
  - New intro pages built in SwiftUI from real app visuals. They replace the four images with English text baked in, one of which has garbled text.
  - *Done when:* the intro reads correctly in English and mirrors in Arabic.
- [ ] **6.9 Onboarding, part 2: setup** · ~140 lines
  - Currency (defaulting to the device region's, if supported), monthly budget (saved as every month) and default payment method. Every step can be skipped.
  - *Done when:* the choices are saved to `Settings`, and skipping every step still leaves a working app.
- [ ] **6.10 Onboarding, part 3: first card and finish** · ~110 lines
  - An optional first card (name, statement day, due day), free for everyone (D35). Then a "Your plan is ready" summary, then the paywall once, which can be closed.
  - *Done when:* finishing shows the paywall once, and closing it lands on Home with the setup applied.
- [ ] **6.11 Review prompt** · ~50 lines
  - Ask for a review after the 5th logged expense, or at the end of the first week under budget. The counts are kept per device.
  - The Rate us row opens the write-review page.
  - *Done when:* in a debug build, the prompt appears on the 5th expense and not before.

## Phase 7 — Everyday tools

- [ ] **7.1 Face ID lock, part 1** · ~120 lines · D16, free
  - `LocalAuthentication`: Face ID or Touch ID, falling back to the passcode. The app locks on launch and on return from the background, and the app switcher shows a cover instead of data. The setting is stored per device. Add `NSFaceIDUsageDescription`.
  - *Done when:* with the lock on, nothing shows before unlocking, after a cold launch or after backgrounding, and cancelling stays locked with a retry button.
- [ ] **7.2 Face ID lock, part 2** · ~50 lines
  - A toggle under Settings → Security, with a note that widgets and Siri still show amounts. It can't be turned on without a device passcode.
  - *Done when:* on a simulator with no passcode, the toggle explains why it can't be turned on.
- [ ] **7.3 Savings goals, part 1** · ~130 lines · D19, D24
  - A Goals section on Home, and a sheet to create a goal: name, emoji, target and optional date.
  - A free user's second goal opens the paywall. A lapsed subscriber keeps their existing goals.
  - *Done when:* a free user can create one goal and is asked to upgrade for a second.
- [ ] **7.4 Savings goals, part 2** · ~140 lines
  - Goal detail shows:
    - progress
    - add or withdraw money (each one its own contribution record)
    - the amount still needed
    - "save X a month to reach it by *date*"
  - Contributions never count as spending.
  - *Done when:* three contributions and a withdrawal show the right total, and two simulators that each add money end up with both contributions.
- [ ] **7.5 CSV export** · ~110 lines · Pro · file builder ⇄ · ✂
  - Columns: ISO date, type, amount, currency code, merchant, category, method, card. Quoting follows RFC 4180, and decimals use `.` whatever the locale. Shared from Settings → Data.
  - *Done when:* a harness checks quotes, commas and line breaks inside merchant names, and an exported file opens correctly in Numbers.

## Phase 8 — Fast logging (Siri, Shortcuts, Control Center, Lock Screen)

- [ ] **8.1 Sentence parser** · ~150 lines · ⇄ needs 2.1
  - Reads a sentence such as "1500 at McDonald's on HBL":
    - the amount
    - the merchant, after "at", "for" or "on"
    - cash, or a card by name or last 4 digits
  - Keywords in English, Arabic and German.
  - *Done when:* a harness passes 30 sample sentences (10 per language), including "Rs 1,500", "15.50" and "١٥٠٠".
- [ ] **8.2 Merchant memory** · ~80 lines · D31
  - A merchant gets the category of its most recent expense. Otherwise it comes from a bundled list of about 100 common merchants (PK, IN, Gulf, US, UK, EU). Otherwise it is Other.
  - *Done when:* after logging "Careem" once as Transport, the next "Careem" picks Transport.
- [ ] **8.3 Cards and categories for Siri** · ~110 lines
  - App entities and queries for cards (by name and last 4) and categories, keyed by the `stableID`s from 1.1.
  - *Done when:* the Shortcuts app lists the user's cards and categories as choices.
- [ ] **8.4 Log Expense intent** · ~140 lines
  - Runs without opening the app:
    1. Asks "What did you spend?"
    2. Parses the answer (8.1).
    3. Picks the category (8.2) and the payment method: the default from 6.7, unless the sentence names a card.
    4. Saves the expense and refreshes the widgets.
    5. Replies "Logged Rs 1,500 · McDonald's · Dining · HBL card".
  - Structured parameters let iOS 27's one-sentence Siri fill it in.
  - *Done when:* the MASTER_PLAN §6.2 sentence logs correctly from the Shortcuts app and from Siri on a device.
- [ ] **8.5 App Shortcuts and spending questions** · ~120 lines
  - App Shortcuts with the app name in every phrase: log an expense, how much I've spent this month, how much budget is left.
  - *Done when:* each phrase works from Siri and from Spotlight.
- [ ] **8.6 "When is my card due?"** · ~70 lines
  - The card is a parameter. The answer gives the date, amount and paid status (from 5.1).
  - *Done when:* asking about a card gives the same date and amount as its tile.
- [ ] **8.7 Control Center button** · ~60 lines · iOS 18+
  - An "Add expense" control in the widget extension that opens the form.
  - *Done when:* on iOS 18 the control opens the form, and on iOS 17 the app builds and runs without it.
- [ ] **8.8 Lock Screen widget: left this month** · ~90 lines · D21, free
  - Circular, rectangular and inline sizes.
  - *Done when:* all three sizes show the same "left" figure as Home.
- [ ] **8.9 Lock Screen widget: next card due** · ~80 lines · free
  - Shows the next card due, or an empty state when there are no cards.
  - *Done when:* it matches the soonest due date on the Cards tab.
- [ ] **8.10 Back Tap and Action Button guide** · ~90 lines
  - A screen under Settings → Shortcuts with the steps to bind the Log Expense shortcut.
  - *Done when:* following the steps on a device logs an expense from a double tap on the back of the phone.
- [ ] **8.11 Siri confirmation with buttons** · ~120 lines · iOS 26+ · ✂
  - An interactive snippet with *Change category* and *Undo*.
  - *Done when:* on iOS 26, both buttons work, and older versions get the spoken reply only.

## Phase 9 — Receipt scanning: dropped (D37)

Dropped on 2026-11-22, with its six steps (9.1–9.6), the camera permission and the 20-receipt test. The number stays so later phase and step numbers don't change.

## Phase 10 — Polish

- [ ] **10.1 Category sheets on the kit** · ~150 lines
  - *Done when:* add and edit category match the new look in light and dark mode.
- [ ] **10.2 Budget and card sheets on the kit** · ~150 lines
  - *Done when:* the budget sheet and the add and edit card sheets match the new look.
- [ ] **10.3 Pickers and info sheets on the kit** · ~120 lines · ✂
  - The currency, emoji, reminders and widget info sheets.
  - *Done when:* no screen still uses fixed font sizes or the old colours.
- [ ] **10.4 Home Screen widgets on the kit** · ~120 lines
  - The three existing widgets match the app's new look (store screenshot 6).
  - *Done when:* all three render in light and dark mode on the Home Screen.

## Phase 11 — Languages and rename

- [ ] **11.1 Computed strings localizable** · ~120 lines
  - About 45 enum and computed display strings (categories, reminder levels, appearance, plans, paywall features…) move to `LocalizedStringResource`.
  - Also the 5 logging-reminder titles and bodies in `NotificationScheduler`, which are plain `String`s today.
  - *Done when:* switching the simulator to German shows no English in those places, once 11.5 has filled the catalog.
- [ ] **11.2 Widgets and Siri phrases localizable** · ~60 lines
  - Widget names and descriptions, and the App Shortcut phrases. The widget names and descriptions are already in the widget catalog (their APIs extract them; checked in 0.3), so this is mainly the Siri phrases and any widget text held in plain `String`s.
  - *Done when:* they appear in the catalogs ready for translation.
- [ ] **11.3 Right-to-left pass** · ~100 lines
  - The tab bar, charts, progress bars, card visuals, chevrons and onboarding, checked in Arabic.
  - *Done when:* every screen mirrors correctly in Arabic.
- [ ] **11.4 Arabic draft**
  - Catalog data, reviewed by a native speaker (Q4).
  - Mark keys that are not words as "Don't translate", for example `X`, `0.00` and `💸` (unless 3.2 has removed them already).
  - *Done when:* the app runs fully in Arabic with no truncation.
- [ ] **11.5 German draft**
  - Catalog data, reviewed by a native speaker (Q4). The "Don't translate" marks from 11.4 apply to every language.
  - *Done when:* the app runs fully in German with no truncation.
- [ ] **11.6 Rename** · ~20 lines · needs Q1
  - `AppInfo.name`, the app and widget display names, and the StoreKit display names.
  - *Done when:* the new name shows everywhere a user can see it, and internal identifiers are unchanged.

- [ ] **11.7 Month labels on the Islamic calendar** · ~30 lines
  - Found in 2.1: on a phone set to the Islamic calendar (the default for `ar_SA`), the month header and month picker show a Hijri month ("Jumada II 1448"), but budgets and history are grouped by Gregorian month (`monthKey`). The label doesn't match the dates under it.
  - The cause: `MonthUtil.fmt` formats with the user's calendar. Pin it to `MonthUtil.gregorian`, so headers name the Gregorian month in the user's language and numerals.
  - Single dates (expense rows, the date picker, card cycles) can stay in the user's calendar: they show the right day either way.
  - Budget months stay Gregorian in 2.4. Hijri budget months would mean a second `monthKey` scheme; if wanted, that is 2.5 work.
  - *Done when:* on `ar_SA` with the Islamic calendar, every month header and the month picker name the Gregorian month whose data they show.

## Phase 12 — Release prep

- [ ] **12.1 Privacy and review check**
  - Confirm "Data Not Collected" is still true and the privacy manifest and usage strings are current. Draft the App Review notes (MASTER_PLAN §11).
  - *Done when:* every "Store and review" box in MASTER_PLAN §11 is ticked, and the review notes are ready to paste.
- [ ] **12.2 TestFlight matrix**
  - Run every scenario in the MASTER_PLAN §11 table on TestFlight builds.
  - *Done when:* every row is ticked, or its failure is fixed or moved to 2.5.
- [ ] **12.3 CloudKit schema to Production** · done after Phase 1, before TestFlight 1
  - Ahmad deploys it once Phase 1 is done and checked, after 1.4 has put the full schema into Development. TestFlight builds sync against Production, and sync breaks for live users without it.
  - If a later step adds a field or model, rerun 1.4's launch argument, then deploy again before the next TestFlight build and before submitting.
  - *Done when:* the CloudKit console shows every new model and field in Production, and a TestFlight build syncs against it.
- [ ] **12.4 Keyword check**
  - Remove the keyword of any feature that slipped (MASTER_PLAN §9.2).
  - *Done when:* every keyword in each listing matches a feature in the submitted build.

---

## Ahmad's track

Work only Ahmad can do, and what it holds up.

| What | Needed by | Holds up |
|---|---|---|
| **Q1** Final app name (overdue since Nov 13) | Nov 21 | 11.6, screenshots, metadata, saying the name to Siri before locking it |
| Featuring nomination in App Store Connect | Nov 21 | MASTER_PLAN §12 |
| **Q4** Translation reviewers for AR and DE | Nov 23 | 11.4–11.5 |
| **Q9** Show card due dates in the free widgets to free users? | Nov 28 | 6.1 |
| **Q2** Final prices, and `sw_lifetime` created in App Store Connect | Nov 27 | sandbox test of 6.2 |
| TestFlight internal group, with two devices on one iCloud account | Nov 28 | TestFlight 1 |
| Test devices on iOS 17, 18, 26 and 27 | Dec 1 | checks in Phase 8 |
| Screenshots per listing, with demo data | Dec 5 | submit |
| Optional: a Spanish (Mexico) listing with extra English keywords for the US store (D36) | Dec 5 | nothing |
| CloudKit schema deployed to Production (12.3) | after Phase 1, before Nov 28 | TestFlight 1, submit |
| In-App Event "New Year Budget Reset" | Dec 11 | MASTER_PLAN §12 |

---

## Slip order

D9's rule: anything not solid at code freeze moves to 2.5. If we fall behind, cut from the top of this list first. When a feature is cut, remove the keyword that promises it before submitting.

1. 8.11 Siri confirmation buttons (iOS 26)
2. 10.3 Pickers and info sheets restyle
3. 5.13–5.14 Card payoff. Remove `debt` and `payoff`.
4. 7.5 CSV export

Everything else is the release: the fixes, free logging, paywall, onboarding, income, savings goals, bills, subscriptions, alerts, Face ID, search, Siri logging, the widgets, and English, Arabic and German.

---

## Schedule check

- **The pace needed.** None of the 85 steps (87 since 1.4 and 11.7 were added) had landed by Nov 22, so the Dec 4 freeze needs about 6–7 steps a day, every day.
- **Parallel help.** The ⇄ steps (2.1, 5.1, 5.8, 5.12, 5.13, 7.5, 8.1) can run in parallel sessions.
- **The fallback.** At 4–5 steps a day, the work needs MASTER_PLAN's fallback dates: freeze Dec 11, submit Dec 14. That still leaves two weeks before Dec 28.
- **Checkpoints.** Nov 24 (end of Phase 3) and Nov 30 (end of Phase 6). More than a day behind at a checkpoint means a choice: take the fallback dates, or cut from the slip order.
