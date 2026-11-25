# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SpendSnap (user-facing name "SpendWise") — a SwiftUI + SwiftData iOS expense tracker with a WidgetKit extension. Xcode project (no SPM manifest, no third-party dependencies), iOS 17.6+, iPhone-only, Swift 5 language mode.

## Build

```bash
xcodebuild -project SpendSnap.xcodeproj -scheme SpendSnap -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath .derivedData build
```

Swap the scheme for `SpendWiseWidgetsExtension` to build the widget target. `.derivedData/` is the repo-local, gitignored derived data path — always pass `-derivedDataPath .derivedData` so incremental builds reuse it.

There is **no test target and no tests** in this project. Verification is: build succeeds, then run in the simulator. For any model change, also run the upgrade test (`docs/upgrade-test/run.sh old`, then `new`, then `clean`), which checks that a store from the live 2.3 build upgrades with every row intact.

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

**But** files the widget target shares from the app folder are listed explicitly as `membershipExceptions` in `SpendSnap.xcodeproj/project.pbxproj` (search for `Exceptions for "SpendSnap" folder in "SpendWiseWidgetsExtension" target`). Today that list is all of `Models/` plus `Services/AppInfo.swift`, `Services/CurrencyHelpers.swift`, `Services/DateUtils.swift` and `Services/Money.swift`.

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

SwiftData with **CloudKit private sync** over an **App Group** shared store (`group.ahmad.SpendWise`, container `iCloud.com.ahmad.SpendWise`). Models: `Expense`, `CategoryEntity`, `CategoryMonthlyBudget`, `Budget`, `CreditCard`, `Settings`, plus (from 2.4) `Income`, `RecurringRule`, `StatementPayment`, `SavingsGoal`, `GoalContribution`. New models store enum values as raw `String`s (`sourceRaw`, `kindRaw`…) with a computed accessor that falls back on unknown values; the raw values are permanent once the CloudKit schema is deployed.

CloudKit imposes hard constraints on every model — **all stored properties must have defaults, relationships must be optional, and `@Attribute(.unique)` is forbidden.** Adding a non-optional property without a default silently breaks container creation at launch.

Consequences that shape the code:

- **Boot fallback** (`SpendSnapApp.swift`): `AppBootController` builds the container with `cloudKitDatabase: .automatic`; on failure it retries with `.none`, and only then shows an error screen. Schema changes must be added in *both* `AppBootController.models` and `SpendWiseWidgets/WidgetModelContainer.swift`, and the two lists must stay identical: the widget opens the same file, and a list missing a model could migrate that model's table away.
- **`Settings` is a singleton by convention, not by constraint.** Because uniqueness can't be enforced, duplicate rows appear (e.g. two devices insert one before first sync). Every reader — app and both widget processes — must fetch with `FetchDescriptor<Settings>(sortBy: Settings.oldestFirst)` and take `.first`, so all processes agree on the same row. `SettingsReconciler.reconcile(in:)` merges duplicates into the oldest row; it runs on `AppEntryView` appearance and again whenever the live `@Query` count rises above 1.
- **Stable ids.** `CreditCard` and `CategoryEntity` carry `stableID: UUID?` for anything that must point at a row across devices (Siri entities, `Settings.defaultCardID`). It is optional and not named `id` on purpose: a non-optional default gives every migrated row, and every row synced from a 2.3 device, the same value, and a field named `id` would replace SwiftData's identity in `ForEach`. `IdentityBackfill.run(in:)` fills `nil` ids at launch and on every foreground, and never changes a set one. Readers must handle `nil`.
- **Rules for new models** (on top of the CloudKit rules above):
  - A model whose rows must be matched across devices (Siri entities, recurrence keys, a stored default) gets `stableID: UUID? = nil`, set in `init`. Never a non-optional `UUID = UUID()` default, and never a field named `id`.
  - Enum values are stored as raw `String`s with a computed accessor that falls back on unknown values.
  - Every relationship is optional, has an inverse, and has a deliberate delete rule (`.nullify` to keep the other side, `.cascade` when it means nothing alone).
  - Field names, types and raw values are permanent once the CloudKit schema is in Production. Additions are fine; renames, removals and type changes are not.
  - Check every model change with the upgrade test (`docs/upgrade-test/README.md`).
  - Then upload it to CloudKit's Development schema and check it, before the schema is deployed again (below).
- **CloudKit schema upload.** Development only learns a field when a record carrying it syncs, so empty optionals and models with no rows would be left out of a deploy to Production. A DEBUG-only launch argument uploads every model and field from `AppBootController.models` (`Services/CloudKitSchemaInit.swift`), using a throwaway store; it never opens the real store. The simulator must be signed into iCloud. Run it after any model change:

  ```bash
  xcrun simctl launch --console-pty 'iPhone 17 Pro' com.ahmad.SpendWise -initCloudKitSchema
  ```

  It prints `CloudKitSchemaInit OK: …` or the error. Check the result with `xcrun cktool export-schema --team-id 8Q2JY29B23 --container-id iCloud.com.ahmad.SpendWise --environment development` (Ahmad's management token is saved in the keychain with `cktool save-token`): every model is a `CD_<Model>` record type and every stored property a `CD_<name>` field.
- **Never run an Xcode debug build of 2.4 on a phone that holds real data.** Debug builds sync with CloudKit's Development environment, real data lives in Production, and the app would push the local store into Development. Use the simulator, or TestFlight builds (Production) once the schema is deployed.
- Widgets open the same store with `cloudKitDatabase: .none` (read-only view of shared data), falling back to an in-memory container so the widget never crashes.

### monthKey

`Expense`, `Budget`, and `CategoryMonthlyBudget` all carry a denormalized `monthKey` string (`"yyyy-MM"`), and month-scoped fetching is done by `#Predicate { $0.monthKey == key }` rather than date ranges. The key is produced by `MonthUtil.monthKey` using a locale-pinned (`en_US_POSIX`) Gregorian formatter.

A month's budget is read only through `Budget.amount(for:in:)` (`Models/Budget.swift`): the month's own `Budget` row, else `Settings.defaultMonthlyBudget` (the "every month" budget, D26), else 0. Home, Insights and the widgets all use it. The budget sheet's "Every month" writes the default and deletes that month's own rows; "This month" updates the month's row and deletes any duplicates.

CloudKit can't keep one `Budget` row per month, so two devices saving the same month before syncing leave two. `Budget.preferred(_:)` picks the one to use everywhere: newest `updatedAt` (set on create and every edit; `nil` on rows from 2.3), then the higher amount, then `id`. `BudgetReconciler.reconcile(in:)` keeps that row and deletes the rest, at launch and on every foreground. `CategoryMonthlyBudget` has `updatedAt` too; reading and cleaning up its duplicates lands in step 3.9. `Budget.carryOverLatest(in:)` runs at launch and, while the default is 0, copies the latest month's budget up to the current month into it, for stores upgraded from 2.3.

**Use `MonthUtil.gregorian`, never `Calendar.current`, for any arithmetic whose result feeds or buckets a `monthKey`** — a user in a Hijri/Buddhist region would otherwise shift the month out from under the key. `MonthUtil.gregorian` pins only the calendar identifier and inherits `firstWeekday`/`timeZone` from the user's settings.

## View patterns

`AppEntryView` → `OnboardingView` (until `settings.onboardingComplete`) → `RootTabView`, which drives a `TabView` with the system tab bar hidden and a hand-rolled `CustomTabBar`. Appearance (`.light`/`.dark`/`.system`) is applied once at `RootTabView` via `preferredColorScheme`.

Every amount field reads its text with `AmountParser.parse` and prefills an edit with `AmountParser.editString` (`Services/AmountParser.swift`). It accepts `12,50`, `1.250,00`, Arabic-Indic and Persian digits and stray currency symbols in any locale. Never use `Decimal(string:)` on user input: it ignores the locale.

Every amount on screen goes through `Money.format(_:code:)` (`Services/Money.swift`) or the `MoneyText` view: the locale's grouping, decimal mark, numerals and symbol position, with the app's own symbol from `CurrencyUtil`. Never build `"\(symbol)\(amount)"`. Text around an amount is a localized string with the amount interpolated, e.g. `Text("Spent: \(Money.format(spent, code: currencyCode))")`. Arabic numerals only appear once the app ships Arabic strings: until then iOS reports an unlocalized app's locale as English-in-the-region.

Two data-access styles coexist, deliberately:

- `@Query` for lists that should track the store live (categories, cards, the settings row).
- Manual `FetchDescriptor` into `@State` arrays for month-scoped data (`HomeView.monthExpenses`, `HistoryView`, `InsightsView`), refetched on `onAppear` and month change.

Those hand-fetched caches hold strong references that a delete does not sweep, so **"Delete all data" posts `.spendWiseDidDeleteAllData`** (defined in `SettingsView.swift`) and every screen holding such a cache clears it in an `onReceive`. Any new screen that caches models by hand must do the same, or SwiftUI will render a body against an invalidated object.

"Delete all data" runs `DataWipe.deleteAll(in:)` (`Services/DataWipe.swift`), which deletes every model except `Settings`, children before parents. **A new model must be added to it**, as well as to the two schema lists.

## Widgets

Three static widgets in `SpendWiseWidgets/`: Month Overview (medium), Weekly Spent, Credit Cards (large). Each `TimelineProvider` opens `WidgetModelContainer.shared`, fetches directly, and returns a single entry with a `.after(+30 min)` refresh policy.

Widgets never observe the store, so **any mutation in the app must call `WidgetRefresh.reloadAll()` after `context.save()`** — currency changes, expense/budget/category/card edits. Existing call sites are the reference.

Deep link: widgets use `SpendWise://addExpense`; `RootTabView.onOpenURL` handles it by switching to the History tab with a deep-link month binding.

## Notifications

`NotificationScheduler` (`Services/NotificationScheduler.swift`) schedules every local notification. Each kind owns its identifiers and only removes those, never `removeAllPendingNotificationRequests`, so changing one kind never wipes another. The logging reminders use `expense-reminder-0`…`-9` (unchanged since 2.3, so updated installs find theirs). New kinds (card alerts, bill reminders) get their own prefix and reuse `requestAuthorizationIfNeeded(onDenied:then:)`.

## Monetization

`StoreKitManager` (StoreKit 2) is the single source of truth for entitlement. Products `sw1` (monthly) and `sw2` (yearly), subscription group `21928894`; `SpendWise Pro.storekit` is the local testing configuration.

Feature gating reads **`storeKit.hasActiveSubscription`** — the persisted `Settings.proUnlocked` field exists but is not what gates anything. The gating pattern is: await `refreshEntitlements()` if `!isEntitlementsLoaded`, then present `GoProSheet` instead of the action (see `HomeView.handleAddExpenseTap`, `HistoryView`, `CreditCardView`). The paywall is also shown once right after onboarding completes.

## Credit card cycles

`cardCycleAndDue(statementDay:dueDay:)` in `DateUtils.swift` derives the current statement window and due date from a card's `statementDay`/`dueDay`, clamping day-of-month to the month's length (`Calendar.clampedDate`). Due date rolls to the following month when `dueDay <= statementDay`. Card spend is the sum of expenses with `date` in `[cycle.start, cycle.end)`.

What a card *shows* comes from `cardStatementToShow(statementDay:dueDay:)`. It returns the last closed statement until the end of its due date, then the open cycle (D25), and `isClosed` says which. The card tile, the card list's snapshot (where the detail sheet opens) and the Credit Cards widget all use it. Card views get their expenses through `CardCycleExpenses(card:cycle:)`, a live `@Query` filtered to one card and one cycle, and never query every expense in the store.

## Growth plan

The v2.4 relaunch (rename, freemium, Siri, bills & cards, income and savings goals, Arabic and German, ASO) is planned in `docs/MASTER_PLAN.md`. Read it before product or App Store work, and keep its decision log and checklists current.

The order of work is `docs/BUILD_ORDER.md`: 88 numbered steps in phases 0–12 (Phase 9 was dropped), plus Ahmad's non-code tasks and the slip order. Take the first unticked step unless Ahmad names another.
