//
//  SKMenu.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/30/24.
//

import Foundation

enum SKMenu: String, CaseIterable, Identifiable {
    case transactions = "Transactions"
    case history = "Transaction History"
    case accounts = "Accounts"
    case trends = "Trends"
    case snapshots = "Snapshots"
    case imports = "Import from Wallet"
    case settings = "Settings"

    var id: Self { self }

    /// Menus available on the current platform. FinanceKit is non-functional when the
    /// iOS app runs on a Mac (its FinanceKitUI symbols are weak-linked and unresolved),
    /// so the Wallet import menu is hidden there.
    static var availableCases: [SKMenu] {
        if ProcessInfo.processInfo.isiOSAppOnMac {
            allCases.filter { $0 != .imports }
        } else {
            allCases
        }
    }
}
