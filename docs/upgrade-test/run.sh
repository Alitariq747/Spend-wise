#!/bin/bash
# Upgrade test: live 2.3 store -> current working tree. See README.md.
#   docs/upgrade-test/run.sh old   build 2.3 (80917e6) with seed data, install it fresh, snapshot "before"
#   docs/upgrade-test/run.sh new   build the working tree, install over it, snapshot "after", compare, check
#   docs/upgrade-test/run.sh clean remove the 2.3 worktree and its build output
# Run from the repo root. Wipes SpendWise from the simulator in `old`.
set -euo pipefail

LIVE_COMMIT=80917e6
SIM="${SIM:-iPhone 17 Pro}"
BUNDLE=com.ahmad.SpendWise
ROOT="$(git rev-parse --show-toplevel)"
HERE="$ROOT/docs/upgrade-test"
WORK="$ROOT/.derivedData/upgrade-test"   # gitignored
WT="$WORK/v23"

store() {
  local g; g=$(xcrun simctl get_app_container "$SIM" "$BUNDLE" groups | cut -f2)
  echo "$g/Library/Application Support/default.store"
}
boot() { xcrun simctl boot "$SIM" 2>/dev/null || true; xcrun simctl bootstatus "$SIM" -b >/dev/null 2>&1; }
launch_and_stop() { xcrun simctl launch "$SIM" "$BUNDLE" "$@" >/dev/null; sleep 12; xcrun simctl terminate "$SIM" "$BUNDLE" || true; sleep 2; }

case "${1:-}" in
old)
  mkdir -p "$WORK"
  [ -d "$WT" ] || git -C "$ROOT" worktree add --detach "$WT" "$LIVE_COMMIT"
  cp "$HERE/UpgradeTestSeed.swift" "$WT/SpendSnap/Services/"
  python3 - "$WT/SpendSnap/Views/Root/AppEntryView.swift" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
hook = "            UpgradeTestSeed.runIfRequested(in: modelContext)\n"
a = "        .task {\n            SettingsReconciler.reconcile(in: modelContext)\n"
if hook not in s:
    assert s.count(a) == 1, "AppEntryView hook point not found"
    s = s.replace(a, "        .task {\n" + hook + "            SettingsReconciler.reconcile(in: modelContext)\n")
    open(p, "w").write(s)
EOF
  (cd "$WT" && xcodebuild -project SpendSnap.xcodeproj -scheme SpendSnap \
     -destination "platform=iOS Simulator,name=$SIM" -derivedDataPath "$WORK/v23-derived" build \
     | grep -E "error:|BUILD (SUCCEEDED|FAILED)")
  boot
  xcrun simctl uninstall "$SIM" "$BUNDLE" || true
  xcrun simctl install "$SIM" "$WORK/v23-derived/Build/Products/Debug-iphonesimulator/SpendSnap.app"
  launch_and_stop -seedUpgradeTest
  sqlite3 "$(store)" < "$HERE/snapshot.sql" > "$WORK/before.txt"
  grep -E "^(count|sum)" "$WORK/before.txt"
  echo "2.3 store seeded. Expect 21 expenses, 3 cards, 4 categories, 3 budgets, 2 category budgets, 1 settings, sum 91651.5."
  ;;
new)
  [ -f "$WORK/before.txt" ] || { echo "Run '$0 old' first."; exit 1; }
  for scheme in SpendSnap SpendWiseWidgetsExtension; do
    (cd "$ROOT" && xcodebuild -project SpendSnap.xcodeproj -scheme "$scheme" \
       -destination "platform=iOS Simulator,name=$SIM" -derivedDataPath .derivedData build \
       | grep -E "error:|BUILD (SUCCEEDED|FAILED)")
  done
  boot
  xcrun simctl install "$SIM" "$ROOT/.derivedData/Build/Products/Debug-iphonesimulator/SpendSnap.app"
  launch_and_stop
  xcrun simctl launch "$SIM" "$BUNDLE" >/dev/null; sleep 10
  xcrun simctl io "$SIM" screenshot "$WORK/after.png" >/dev/null 2>&1 || true
  xcrun simctl terminate "$SIM" "$BUNDLE" || true; sleep 2
  DB="$(store)"
  sqlite3 "$DB" < "$HERE/snapshot.sql" > "$WORK/after.txt"
  if diff "$WORK/before.txt" "$WORK/after.txt"; then echo "PASS user data identical"; else echo "FAIL user data changed"; fi
  sqlite3 "$DB" "SELECT 'cards: rows/with id/distinct', COUNT(*), COUNT(ZSTABLEID), COUNT(DISTINCT ZSTABLEID) FROM ZCREDITCARD;
                 SELECT 'categories: rows/with id/distinct', COUNT(*), COUNT(ZSTABLEID), COUNT(DISTINCT ZSTABLEID) FROM ZCATEGORYENTITY;"
  echo "tables: $(sqlite3 "$DB" "SELECT group_concat(name, ' ') FROM sqlite_master WHERE type='table' AND name LIKE 'Z%' AND name NOT LIKE 'Z\_%' ESCAPE '\\'")"
  APPDATA=$(xcrun simctl get_app_container "$SIM" "$BUNDLE" data)
  if plutil -p "$APPDATA/Library/Preferences/$BUNDLE.plist" 2>/dev/null | grep -i AppBoot; then
    echo "FAIL boot error recorded (the app fell back or failed to open the store)"
  else echo "PASS no boot error"; fi
  echo "Screenshot (should show Home with the seeded November data): $WORK/after.png"
  ;;
clean)
  git -C "$ROOT" worktree remove --force "$WT" 2>/dev/null || true
  git -C "$ROOT" worktree prune
  rm -rf "$WORK"
  ;;
*) sed -n '2,6p' "$0"; exit 1 ;;
esac
