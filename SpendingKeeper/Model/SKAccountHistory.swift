//
//  SKAccountHistory.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/29/24.
//

import Foundation
import SwiftData

struct SKAccountHistory {
    
    var account: SKAccount?
    var recordUid: UUID
    var previoudBalance: Double
    var newBalance: Double
    var date: Date
    
    init(account: SKAccount? = nil, recordUid: UUID, previoudBalance: Double, newBalance: Double, date: Date = .now) {
        self.account = account
        self.recordUid = recordUid
        self.previoudBalance = previoudBalance
        self.newBalance = newBalance
        self.date = date
    }
}
