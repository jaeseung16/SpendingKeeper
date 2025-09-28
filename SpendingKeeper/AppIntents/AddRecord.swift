//
//  AddRecord.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 9/21/25.
//

import AppIntents
import SwiftUI

struct AddRecord: AppIntent {
    
    static let title: LocalizedStringResource = "Add a transaction"

    static let description = IntentDescription("Opens SpendingKeeper to allow you to add a new transaction.")
    
    static let openAppWhenRun: Bool = true
    
    @Dependency private var navigator: SKNavigator
    
    @MainActor
    func perform() async throws -> some IntentResult {
        navigator.navigateToAddRecordView()
        return .result()
    }

}
