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

## Working in steps

Ahmad works in small chunks. These rules apply to every code change, whether it comes from `docs/BUILD_ORDER.md` or from a new request:

- **Size.** A step adds or changes at most ~150 lines of Swift. The hard limit is 200. Count the insertions from `git diff --numstat`. Deletions, String Catalog data, asset JSON, `project.pbxproj` and docs don't count.
- **Split before coding.** If a step or request would go over the limit, split it into sub-steps (`3.5a`, `3.5b`…) without being asked. Each sub-step must build and run on its own. Write the sub-steps into `docs/BUILD_ORDER.md` first, then do them one at a time.
- **Plan first.** Start each step with a short plan in chat: files, approach, estimated size, and how it will be checked. Wait for Ahmad's go-ahead before writing code.
- **Finish cleanly.** A step is done when:
  - both targets build
  - its **Done when** line has been checked
  - it is ticked in `docs/BUILD_ORDER.md`, and its box in `docs/MASTER_PLAN.md` §6 is ticked when it completes a feature
  - this file is updated if the step changed something it describes

  Each step should be committable on its own. **Ahmad commits every step himself in Xcode, and sets the version and build number there too.** Never run `git commit` or edit `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION`; end a step by saying it is ready to commit, with a suggested message.
- **Pure logic without a test target.** Parsers, date maths, payoff maths and CSV building live in Foundation-only files. Check them by compiling the file with a throwaway `main.swift` in the scratchpad (`swiftc File.swift main.swift -o check && ./check`) and running the step's cases.
- **Cold starts.** Each step in `BUILD_ORDER.md` is written so a fresh session can pick it up. Read the step, the decisions it cites, and the files it names.

## Targets and file membership

Two targets: `SpendSnap` (app) and `SpendWiseWidgetsExtension` (widget bundle).

The project uses Xcode's **file-system-synchronized groups** (`PBXFileSystemSynchronizedRootGroup`). A new `.swift` file dropped into `SpendSnap/` or `SpendWiseWidgets/` is picked up by its own target automatically — no pbxproj edit needed.

**But** files the widget target shares from the app folder are listed explicitly as `membershipExceptions` in `SpendSnap.xcodeproj/project.pbxproj` (search for `Exceptions for "SpendSnap" folder in "SpendWiseWidgetsExtension" target`). Today that list is all of `Models/` plus `Services/AppInfo.swift`, `Services/CurrencyHelpers.swift` and `Services/DateUtils.swift`.

If widget code needs another app file, it must be added to that exception list or the widget target won't compile.

`AppInfo` (`Services/AppInfo.swift`) is the one home for the user-facing app name, Pro name, App Store id, support email and legal URLs. User-facing text uses `AppInfo.name`/`AppInfo.proName`, never a literal "SpendWise". Internal identifiers (bundle IDs, `SpendWise://`, the App Group, the CloudKit container) stay literal and never change with a rename.

## Strings and languages

Each target has its own String Catalog: `SpendSnap/Localizable.xcstrings` and `SpendWiseWidgets/Localizable.xcstrings`. Languages are English (source), Arabic (`ar`) and German (`de`). Every new user-facing string goes through a catalog: SwiftUI literals (`Text("…")`, button titles) are extracted automatically; a string held in a plain `String` is not, and needs `String(localized:)` or `LocalizedStringResource`.

`xcodebuild` does not write new strings back into the catalogs. After a build, refresh them from the build's `.stringsdata`:

```bash
bash -c 'D=.derivedData/Build/Intermediates.noindex/SpendSnap.build/Debug-iphonesimulator
for p in SpendSnap/Localizable.xcstrings:SpendSnap SpendWiseWidgets/Localizable.xcstrings:SpendWiseWidgetsExtension; do
  f=( $(ls $D/${p##*:}.build/Objects-normal/arm64/*.stringsdata | grep -v /Generated) )
  xcrun xcstringstool sync "${p%%:*}" --stringsdata "${f[@]}"
done'
```

Building once in Xcode does the same.

## Data layer

SwiftData with **CloudKit private sync** over an **App Group** shared store (`group.ahmad.SpendWise`, container `iCloud.com.ahmad.SpendWise`). Models: `Expense`, `CategoryEntity`, `CategoryMonthlyBudget`, `Budget`, `CreditCard`, `Settings`.

CloudKit imposes hard constraints on every model — **all stored properties must have defaults, relationships must be optional, and `@Attribute(.unique)` is forbidden.** Adding a non-optional property without a default silently breaks container creation at launch.

Consequences that shape the code:

- **Boot fallback** (`SpendSnapApp.swift`): `AppBootController` builds the container with `cloudKitDatabase: .automatic`; on failure it retries with `.none`, and only then shows an error screen. Schema changes must be added in *both* this schema list and `SpendWiseWidgets/WidgetModelContainer.swift`.
- **`Settings` is a singleton by convention, not by constraint.** Because uniqueness can't be enforced, duplicate rows appear (e.g. two devices insert one before first sync). Every reader — app and both widget processes — must fetch with `FetchDescriptor<Settings>(sortBy: Settings.oldestFirst)` and take `.first`, so all processes agree on the same row. `SettingsReconciler.reconcile(in:)` merges duplicates into the oldest row; it runs on `AppEntryView` appearance and again whenever the live `@Query` count rises above 1.
- **Stable ids.** `CreditCard` and `CategoryEntity` carry `stableID: UUID?` for anything that must point at a row across devices (Siri entities, `Settings.defaultCardID`). It is optional and not named `id` on purpose: a non-optional default gives every migrated row, and every row synced from a 2.3 device, the same value, and a field named `id` would replace SwiftData's identity in `ForEach`. `IdentityBackfill.run(in:)` fills `nil` ids at launch and on every foreground, and never changes a set one. Readers must handle `nil`.
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

## Growth plan

The v2.4 relaunch (rename, freemium, Siri, bills & cards, income and savings goals, Arabic and German, ASO) is planned in `docs/MASTER_PLAN.md`. Read it before product or App Store work, and keep its decision log and checklists current.

The order of work is `docs/BUILD_ORDER.md`: 85 numbered steps in phases 0–12 (Phase 9 was dropped), plus Ahmad's non-code tasks and the slip order. Take the first unticked step unless Ahmad names another.
