//
//  SKAccount.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/29/24.
//

import Foundation
import SwiftData

@Model
class SKAccount {

    var uid: UUID
    var name: String
    var balance: Double
    var balanceDate: Date
    var created: Date
    var updated: Date
    
    init(uid: UUID = .init(), 
         name: String,
         balance: Double = 0.0,
         balanceDate: Date = .now,
         created: Date = .now,
         updated: Date = .now) {
        self.uid = uid
        self.name = name
        self.balance = balance
        self.balanceDate = balanceDate
        self.created = created
        self.updated = updated
    }
    
}