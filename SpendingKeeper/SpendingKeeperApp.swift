//
//  SpendingKeeperApp.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/26/24.
//

import SwiftUI
import SwiftData
import AppIntents

@main
struct SpendingKeeperApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SKAccount.self, SKRecord.self, SKSnapshot.self,
            SKSnapshotSpending.self, SKSnapshotIncome.self, SKSnapshotRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var navigator = SKNavigator.shared

    init() {
        let navigator = self.navigator
        AppDependencyManager.shared.add(dependency: navigator)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(SKViewModel(modelContext: sharedModelContainer.mainContext))
        .environment(navigator)
    }
}
