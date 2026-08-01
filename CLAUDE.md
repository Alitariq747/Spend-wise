# CLAUDE.md — SpendWise

Context and working rules for Claude Code in this repository. Read this before touching any file.

---

## 1. Project

**SpendWise** — iPhone-only expense and budget tracker, currently pre-1.0, preparing for first App Store submission.

| | |
|---|---|
| App target | `SpendSnap` |
| Widget target | `SpendWiseWidgetsExtension` |
| UI | SwiftUI |
| Persistence | SwiftData with CloudKit mirroring (private database) |
| Purchases | StoreKit 2 (`sw1`, `sw2` — subscription group "SpendWise Pro") |
| CloudKit container | `iCloud.com.ahmad.SpendWise` |
| Min iOS | 17.6 |
| Size | ~9k LOC, English-only, no test target |
| Networking | None. No analytics, no third-party SDKs, no secrets |

Data flows app ⇄ SwiftData store ⇄ CloudKit; the widget extension reads the same store through an app group.

---

## 2. Layout

```
SpendSnap/
  Models/          Expenses, Settings, CategoryEntity, Budget, CategoryMonthlyBudget
  Services/        DateUtils, CurrencyHelpers, ExpenseHelpers, InsightsHelpers,
                   StoreKitManager, iCloudStatusManager, WidgetModelContainer
  Views/
    Root/          AppEntryView, RootTabView
    Home/          HomeView, AddExpenseSheet, AddBudgetSheet, AddCategorySheet, CategoryEditSheet
    History/       HistoryView, ExpenseDetailSheet
    Insights/      InsightsView, TrendsView, OverviewView
    Settings/      SettingsView, GoProSheet, AppearanceRow, CurrencyPickerSheet, RemindersSelectionView
SpendWiseWidgets/  MonthOverviewWidget, WeeklySpentWidget, CreditCardsWidget, SpendWiseWidgetsBundle
```

---

## 3. Hard constraints

These are non-negotiable properties of the codebase. Violating any of them breaks the app silently.

**CloudKit schema rules.** Every `@Model` attribute must have a default value. Every relationship must be optional. `@Attribute(.unique)` is forbidden — CloudKit mirroring rejects it. This means uniqueness is never enforced by the store; it must be reconciled in code.

**`monthKey` is a persisted join key.** It is stored on `Expense`, `Budget`, and `CategoryMonthlyBudget` rows and used to join them across the whole app. Its format is `yyyy-MM`, Gregorian, ASCII digits, always. Never derive it with a locale-inheriting `DateFormatter`.

**The widget runs in a separate process.** Anything shared between app and widget (`CurrencyUtil`, the model container, the app group) must be safe to touch from two processes. Any mutation in the app that changes displayed numbers must reload widget timelines.

**No test target exists.** Do not create one, or add test files, unless the task explicitly asks for it.

**Release builds compile with zero warnings.** Keep it that way — do not introduce a warning as a side effect of a fix.

---

## 4. Conventions

- Small, focused types. Prefer extracting a helper over growing a view body.
- One source of truth per concern. If a formatter, key, or computation already exists in `Services/`, use it — do not write a second local version. Several duplicates exist today and are being consolidated; never add a third.
- Currency values are `Decimal`. Never `Double`. Never interpolate a `Decimal` directly into user-facing text — it must go through the shared money formatter.
- Guard against division by zero (`safeProgress`, `ratio` already do this — follow the pattern).
- No force unwraps in display paths. `guard let … else { return <neutral value> }`.
- `print()` only inside `#Preview` blocks or wrapped in `#if DEBUG`.
- Do not swallow errors from `modelContext.save()` without at least logging.

---

## 5. Current work

The repo is being brought to submission-readiness against a production audit. Work proceeds **one scoped task per session**. The current task is stated in the prompt you receive — nothing else is in scope.

Order of work (for context only; do not run ahead):

1. `monthKey` locale/calendar fix
2. Push Notifications capability
3. Legal URLs committed and verified
4. Paywall gating story + copy
5. Build number normalisation
6. `Settings` singleton de-duplication
7. Delete-All-Data preserving onboarding state
8. Money formatting pass
9. Foreground entitlement refresh + widget reload coverage
10. Accessibility, widget deep link, dark mode, insights, dead code

---

## 6. Rules of engagement

**Scope.** Do exactly the task described. If you notice something else broken, name it at the end of your response under "Noticed, not changed" — do not fix it.

**Before editing.** State the files you intend to touch and why. If the task touches more than three files, briefly outline the plan and pause for confirmation.

**Edits.** Prefer the smallest change that fully solves the problem. Do not reformat, reorganise imports, or rename unrelated symbols. Do not "improve" adjacent code.

**Deletions.** Never delete a file without listing its call sites first and confirming there are zero.

**Verification.** After each change, build both targets in Release and report the result. Zero warnings is the bar.

**Reporting.** End with: what changed (file + line), why, what you could not verify, and anything that needs a device or App Store Connect to confirm.

**Uncertainty.** If a fix depends on a decision only the developer can make (gating policy, product naming, migration strategy), stop and ask. Do not pick one and proceed.
