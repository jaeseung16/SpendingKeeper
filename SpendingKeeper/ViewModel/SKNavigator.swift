//
//  Navigator.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 9/21/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class SKNavigator {
    static let shared = SKNavigator()
    
    var menu: SKMenu? = .transactions
    var presentAddRecordView = false
    var selectedTrend: SKTrend?
    
    func navigate(to menu: SKMenu) {
        self.menu = menu
    }
    
    func navigateToAddRecordView() {
        self.menu = .transactions
        self.presentAddRecordView = true
    }
    
    func navigateToImportTransactionsView() {
        self.menu = .imports
    }
    
    func navigateToDailyTrends() {
        self.menu = .trends
        self.selectedTrend = .daily
    }
}
