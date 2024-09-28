//
//  SKMenu.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/30/24.
//

import Foundation

enum SKMenu: String, CaseIterable, Identifiable {
    case transactions = "Transactions"
    case accounts = "Accounts"
    case trends = "Trends"
    case snapshots = "Snapshots"
    case imports = "Import from Wallet"
    
    var id: Self { self }
}
