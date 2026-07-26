//
//  SKRecord.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/29/24.
//

import Foundation
import SwiftData

@Model
class SKRecord {
    
    var uid: UUID = UUID()
    var recordDate: Date = Date.now
    var recordDescription: String = ""
    var transactionType: SKTransaction = SKTransaction.spending
    var accountName: String = ""
    var accountId: UUID?
    var amount: Double = 0.0
    var created: Date = Date.now
    var updated: Date = Date.now

    init(uid: UUID = .init(), 
         recordDate: Date = .now,
         recordDescription: String = "",
         transactionType: SKTransaction = .spending,
         accountName: String = "",
         accountId: UUID? = nil,
         amount: Double = 0.0,
         created: Date = .now,
         updated: Date = .now) {
        self.uid = uid
        self.recordDate = recordDate
        self.recordDescription = recordDescription
        self.transactionType = transactionType
        self.accountName = accountName
        self.accountId = accountId
        self.amount = amount
        self.created = created
        self.updated = updated
    }
}
