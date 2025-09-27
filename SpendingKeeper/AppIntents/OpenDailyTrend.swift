//
//  OpenDailyTrend.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 9/27/25.
//

import AppIntents
import SwiftUI

struct OpenSpendingTrend: AppIntent {
    
    static let title: LocalizedStringResource = "Open spending trends"

    static let description = IntentDescription("Opens the app and shows the daily spending trend this month.")
    
    @Dependency private var navigator: SKNavigator
    
    static let openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        navigator.navigateToDailyTrends()
        return .result()
    }
    
}
