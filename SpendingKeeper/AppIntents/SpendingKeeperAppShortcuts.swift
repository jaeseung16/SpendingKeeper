import AppIntents

struct SpendingKeeperAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddRecord(),
            phrases: [
                "Add a transaction to \(.applicationName)",
                "Open \(.applicationName) and add a transaction",
            ],
            shortTitle: "Add a transaction",
            systemImageName: "plus"
        )
        AppShortcut(
            intent: ImportFromWallet(),
            phrases: [
                "Import transactions to \(.applicationName)",
                "Open \(.applicationName) and import transactions",
            ],
            shortTitle: "Import transactions",
            systemImageName: "square.and.arrow.down.on.square"
        )
        AppShortcut(
            intent: OpenSpendingTrend(),
            phrases: [
                "Open \(.applicationName) and show daily spending trend this month",
            ],
            shortTitle: "Spending trend",
            systemImageName: "chart.line.uptrend.xyaxis"
        )
    }
}
