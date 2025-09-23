//
//  OpenImportFromWallet.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 9/21/25.
//

import AppIntents
import SwiftUI

struct ImportFromWallet: AppIntent {
    
    static let title: LocalizedStringResource = "Import transactions"

    static let description = IntentDescription("Opens the app and goes to import transactions from Wallet.")
    
    @Dependency private var navigator: SKNavigator
    
    static let openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        navigator.navigateToImportTransactionsView()
        return .result()
    }

}
