# Upgrade test

Checks that a store written by the **live 2.3 build** (commit `80917e6`, approved 2026-08-25) upgrades to the current working tree with every row intact. Run it for any step that changes a model (Phase 1, and any later step that adds a field).

It needs no taps and no iCloud account: the data goes in through a debug launch argument, and the check reads the SQLite file directly.

## Run it

From the repo root:

```bash
docs/upgrade-test/run.sh old
```

```bash
docs/upgrade-test/run.sh new
```

```bash
docs/upgrade-test/run.sh clean
```

- **old**: builds `80917e6` in a throwaway git worktree under `.derivedData/upgrade-test/`, with `UpgradeTestSeed.swift` added and hooked into `AppEntryView`. It removes SpendWise from the simulator, installs 2.3, seeds it with `-seedUpgradeTest`, and snapshots the store to `before.txt`.
- **new**: builds both targets from the working tree, installs over the 2.3 app as an App Store update would, launches twice, snapshots to `after.txt`, and checks:
  - user data identical (`diff` of the two snapshots)
  - every card and category has a distinct `stableID`
  - the expected tables exist
  - no `AppBoot.lastError` (the app didn't fall back to running without sync)
  - a screenshot of Home at `.derivedData/upgrade-test/after.png`
- **clean**: removes the worktree and its build output.

Nothing from the worktree is ever committed.

## The seed (2.3 data)

21 expenses over Sep–Nov 2026 (cash and card, some with decimals), 3 cards (two both named "Faysal", to prove distinct ids), 4 categories including a system "Other", 3 month budgets, 2 category budgets, and Settings with PKR, dark mode and onboarding finished. Total spent: 91,651.5.

## When a step adds a model

`snapshot.sql` covers the 2.3 tables only, which is what "user data intact" means. For a new model, also check by hand that its table and columns exist (`PRAGMA table_info(Z<MODEL>)` on the store). For delete rules or other behaviour, add a throwaway debug launch argument in a **separate scratch worktree** of the working tree (never in the repo), as 1.2 did for its card and category delete check.
