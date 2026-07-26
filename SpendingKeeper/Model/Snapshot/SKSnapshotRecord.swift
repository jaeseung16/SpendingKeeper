//
//  SKSnapshotRecord.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/17/24.
//

import Foundation
import SwiftData

@Model
class SKSnapshotRecord {
    
    var recordDate: Date = Date.now
    var recordDescription: String = ""
    var transactionType: SKTransaction = SKTransaction.spending
    var accountName: String = ""
    var amount: Double = 0.0
    var snapshot: SKSnapshot?
    
    init(recordDate: Date, 
         recordDescription: String,
         transactionType: SKTransaction,
         accountName: String,
         amount: Double,
         snapshot: SKSnapshot? = nil) {
        self.recordDate = recordDate
        self.recordDescription = recordDescription
        self.transactionType = transactionType
        self.accountName = accountName
        self.amount = amount
        self.snapshot = snapshot
    }
    
}
