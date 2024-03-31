//
//  SKTransaction.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/29/24.
//

import Foundation

enum SKTransaction: String, CaseIterable, Identifiable, Codable {
    case income
    case spending
    
    var id: Self { self }
}
