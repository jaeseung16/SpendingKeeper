import AppIntents

struct SpendingKeeperAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddRecord(),
            phrases: [
                "Open \(.applicationName) and add a transaction",
            ],
            shortTitle: "Add a transaction",
            systemImageName: "plus"
        )
        AppShortcut(
            intent: ImportFromWallet(),
            phrases: [
                "Open \(.applicationName) and import transactions",
            ],
            shortTitle: "Import transactions",
            systemImageName: "square.and.arrow.down.on.square"
        )
    }
}
