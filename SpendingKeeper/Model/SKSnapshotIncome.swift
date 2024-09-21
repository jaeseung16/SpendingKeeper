//
//  SKSnapshotIncome.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/11/24.
//

import Foundation
import SwiftData

@Model
class SKSnapshotIncome: SKSnapshotChartData {
    
    var accoundId: UUID = UUID()
    var accountName: String = ""
    var total: Double = 0.0
    var snapshot: SKSnapshot?
    
    init(accoundId: UUID = .init(),
         accountName: String = "",
         total: Double = 0.0,
         snapshot: SKSnapshot? = nil) {
        self.accoundId = accoundId
        self.accountName = accountName
        self.total = total
        self.snapshot = snapshot
    }
}
