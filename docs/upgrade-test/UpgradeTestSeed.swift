// Upgrade-test seed for the live 2.3 build (commit 80917e6). NOT part of any target:
// run.sh copies it into a throwaway 2.3 worktree. See README.md.
import Foundation
import SwiftData

enum UpgradeTestSeed {
    @MainActor
    static func runIfRequested(in ctx: ModelContext) {
        guard ProcessInfo.processInfo.arguments.contains("-seedUpgradeTest") else { return }
        guard ((try? ctx.fetchCount(FetchDescriptor<Expense>())) ?? 0) == 0 else { return }
        let settings = (try? ctx.fetch(FetchDescriptor<Settings>(sortBy: Settings.oldestFirst)))?.first ?? {
            let s = Settings(); ctx.insert(s); return s
        }()
        settings.onboardingComplete = true
        settings.currencyCode = "PKR"
        settings.appearanceRaw = AppAppearance.dark.rawValue
        let groceries = CategoryEntity(name: "Groceries", emoji: "🛒", monthlyBudget: 20000, colorHex: "22C55E")
        let dine = CategoryEntity(name: "Dine out", emoji: "🍽️", monthlyBudget: 8000, colorHex: "F97316")
        let transport = CategoryEntity(name: "Transport", emoji: "🚗", colorHex: "3B82F6")
        let other = CategoryEntity(name: "Other", emoji: "📁", isSystemOther: true)
        [groceries, dine, transport, other].forEach { ctx.insert($0) }
        let faysal = CreditCard(name: "Faysal", cycleLimit: 150000, statementDay: 12, dueDay: 25, color: .roseGold)
        let meezan = CreditCard(name: "Meezan Visa", cycleLimit: 80000, statementDay: 1, dueDay: 21, color: .graphite)
        let faysal2 = CreditCard(name: "Faysal", cycleLimit: 50000, statementDay: 5, dueDay: 28, color: .silver)
        [faysal, meezan, faysal2].forEach { ctx.insert($0) }
        var cal = Calendar(identifier: .gregorian); cal.timeZone = .current
        func d(_ m: Int, _ day: Int) -> Date { cal.date(from: DateComponents(year: 2026, month: m, day: day, hour: 12))! }
        let rows: [(Int, Int, Decimal, CategoryEntity, CreditCard?, String)] = [
            (9, 2, 4500, groceries, nil, "Imtiaz"), (9, 5, 1250.50, dine, faysal, "Kolachi"),
            (9, 9, 800, transport, nil, "Careem"), (9, 14, 12000, groceries, meezan, "Metro"),
            (9, 20, 650, other, nil, ""), (9, 27, 3200, dine, faysal2, "Butlers"),
            (10, 1, 5600, groceries, nil, "Imtiaz"), (10, 3, 950.75, transport, faysal, "Uber"),
            (10, 8, 2100, dine, nil, "Cafe Aylanto"), (10, 12, 15000, groceries, meezan, "Carrefour"),
            (10, 18, 400, other, nil, ""), (10, 22, 7800, dine, faysal, "Monal"),
            (10, 30, 1200, transport, faysal2, "Shell"),
            (11, 1, 6300, groceries, nil, "Imtiaz"), (11, 4, 1750.25, dine, meezan, "Kababjees"),
            (11, 7, 600, transport, nil, "Careem"), (11, 10, 9900, groceries, faysal, "Metro"),
            (11, 13, 300, other, nil, ""), (11, 16, 4100, dine, faysal2, "Xander's"),
            (11, 19, 2250, transport, meezan, "PSO"), (11, 21, 11000, groceries, nil, "Al-Fatah"),
        ]
        for (m, day, amount, cat, card, merchant) in rows {
            let e = Expense(amount: amount, date: d(m, day), merchant: merchant, category: cat, method: card == nil ? .cash : .card)
            ctx.insert(e); e.card = card
        }
        ctx.insert(Budget(monthKey: "2026-09", amount: 60000))
        ctx.insert(Budget(monthKey: "2026-10", amount: 65000))
        ctx.insert(Budget(monthKey: "2026-11", amount: 70000))
        ctx.insert(CategoryMonthlyBudget(category: groceries, monthKey: "2026-11", amount: 25000))
        ctx.insert(CategoryMonthlyBudget(category: dine, monthKey: "2026-10", amount: 9000))
        try? ctx.save()
    }
}
