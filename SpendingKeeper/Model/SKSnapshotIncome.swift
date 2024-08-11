//
//  SKSnapshotIncome.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/11/24.
//

import Foundation
import SwiftData

@Model
class SKSnapshotIncome {
    
    var accoundId: UUID = UUID()
    var accountName: String = ""
    var total: Double = 0.0
    var snapshot: SKSnapshot?
    
    init(accoundId: UUID = .init(),
         accountName: String = "",
         total: Double = 0.0) {
        self.accoundId = accoundId
        self.accountName = accountName
        self.total = total
    }
}
