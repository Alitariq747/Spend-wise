# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SpendSnap (user-facing name "SpendWise") — a SwiftUI + SwiftData iOS expense tracker with a WidgetKit extension. Xcode project (no SPM manifest, no third-party dependencies), iOS 17.6+, iPhone-only, Swift 5 language mode.

## Build

```bash
xcodebuild -project SpendSnap.xcodeproj -scheme SpendSnap -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath .derivedData build
```

Swap the scheme for `SpendWiseWidgetsExtension` to build the widget target. `.derivedData/` is the repo-local, gitignored derived data path — always pass `-derivedDataPath .derivedData` so incremental builds reuse it.

There is **no test target and no tests** in this project. Verification is: build succeeds, then run in the simulator.

## Targets and file membership

Two targets: `SpendSnap` (app) and `SpendWiseWidgetsExtension` (widget bundle).

The project uses Xcode's **file-system-synchronized groups** (`PBXFileSystemSynchronizedRootGroup`). A new `.swift` file dropped into `SpendSnap/` or `SpendWiseWidgets/` is picked up by its own target automatically — no pbxproj edit needed.

**But** files the widget target shares from the app folder are listed explicitly as `membershipExceptions` in `SpendSnap.xcodeproj/project.pbxproj` (search for `Exceptions for "SpendSnap" folder in "SpendWiseWidgetsExtension" target`). Today that list is all of `Models/` plus `Services/CurrencyHelpers.swift` and `Services/DateUtils.swift`. If widget code needs another app file, it must be added to that exception list or the widget target won't compile.

## Data layer

SwiftData with **CloudKit private sync** over an **App Group** shared store (`group.ahmad.SpendWise`, container `iCloud.com.ahmad.SpendWise`). Models: `Expense`, `CategoryEntity`, `CategoryMonthlyBudget`, `Budget`, `CreditCard`, `Settings`.

CloudKit imposes hard constraints on every model — **all stored properties must have defaults, relationships must be optional, and `@Attribute(.unique)` is forbidden.** Adding a non-optional property without a default silently breaks container creation at launch.

Consequences that shape the code:

- **Boot fallback** (`SpendSnapApp.swift`): `AppBootController` builds the container with `cloudKitDatabase: .automatic`; on failure it retries with `.none`, and only then shows an error screen. Schema changes must be added in *both* this schema list and `SpendWiseWidgets/WidgetModelContainer.swift`.
- **`Settings` is a singleton by convention, not by constraint.** Because uniqueness can't be enforced, duplicate rows appear (e.g. two devices insert one before first sync). Every reader — app and both widget processes — must fetch with `FetchDescriptor<Settings>(sortBy: Settings.oldestFirst)` and take `.first`, so all processes agree on the same row. `SettingsReconciler.reconcile(in:)` merges duplicates into the oldest row; it runs on `AppEntryView` appearance and again whenever the live `@Query` count rises above 1.
- Widgets open the same store with `cloudKitDatabase: .none` (read-only view of shared data), falling back to an in-memory container so the widget never crashes.

### monthKey

`Expense`, `Budget`, and `CategoryMonthlyBudget` all carry a denormalized `monthKey` string (`"yyyy-MM"`), and month-scoped fetching is done by `#Predicate { $0.monthKey == key }` rather than date ranges. The key is produced by `MonthUtil.monthKey` using a locale-pinned (`en_US_POSIX`) Gregorian formatter.

**Use `MonthUtil.gregorian`, never `Calendar.current`, for any arithmetic whose result feeds or buckets a `monthKey`** — a user in a Hijri/Buddhist region would otherwise shift the month out from under the key. `MonthUtil.gregorian` pins only the calendar identifier and inherits `firstWeekday`/`timeZone` from the user's settings.

## View patterns

`AppEntryView` → `OnboardingView` (until `settings.onboardingComplete`) → `RootTabView`, which drives a `TabView` with the system tab bar hidden and a hand-rolled `CustomTabBar`. Appearance (`.light`/`.dark`/`.system`) is applied once at `RootTabView` via `preferredColorScheme`.

Two data-access styles coexist, deliberately:

- `@Query` for lists that should track the store live (categories, cards, the settings row).
- Manual `FetchDescriptor` into `@State` arrays for month-scoped data (`HomeView.monthExpenses`, `HistoryView`, `InsightsView`), refetched on `onAppear` and month change.

Those hand-fetched caches hold strong references that a delete does not sweep, so **"Delete all data" posts `.spendWiseDidDeleteAllData`** (defined in `SettingsView.swift`) and every screen holding such a cache clears it in an `onReceive`. Any new screen that caches models by hand must do the same, or SwiftUI will render a body against an invalidated object.

## Widgets

Three static widgets in `SpendWiseWidgets/`: Month Overview (medium), Weekly Spent, Credit Cards (large). Each `TimelineProvider` opens `WidgetModelContainer.shared`, fetches directly, and returns a single entry with a `.after(+30 min)` refresh policy.

Widgets never observe the store, so **any mutation in the app must call `WidgetRefresh.reloadAll()` after `context.save()`** — currency changes, expense/budget/category/card edits. Existing call sites are the reference.

Deep link: widgets use `SpendWise://addExpense`; `RootTabView.onOpenURL` handles it by switching to the History tab with a deep-link month binding.

## Monetization

`StoreKitManager` (StoreKit 2) is the single source of truth for entitlement. Products `sw1` (monthly) and `sw2` (yearly), subscription group `21928894`; `SpendWise Pro.storekit` is the local testing configuration.

Feature gating reads **`storeKit.hasActiveSubscription`** — the persisted `Settings.proUnlocked` field exists but is not what gates anything. The gating pattern is: await `refreshEntitlements()` if `!isEntitlementsLoaded`, then present `GoProSheet` instead of the action (see `HomeView.handleAddExpenseTap`, `HistoryView`, `CreditCardView`). The paywall is also shown once right after onboarding completes.

## Credit card cycles

`cardCycleAndDue(statementDay:dueDay:)` in `DateUtils.swift` derives the current statement window and due date from a card's `statementDay`/`dueDay`, clamping day-of-month to the month's length (`Calendar.clampedDate`). Due date rolls to the following month when `dueDay <= statementDay`. Card spend is the sum of expenses with `date` in `[cycle.start, cycle.end)`.
