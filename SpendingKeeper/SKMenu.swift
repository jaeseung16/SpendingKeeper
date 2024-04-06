//
//  SKMenu.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/30/24.
//

import Foundation

enum SKMenu: String, CaseIterable, Identifiable {
    case transactions
    case accounts
    case trends
    
    var id: Self { self }
}
