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

    var uid: UUID = UUID()
    var name: String = ""
    var statementDay: SKAccountStatementDay = SKAccountStatementDay.eom
    var created: Date = Date.now
    var updated: Date = Date.now
    
    init(uid: UUID = .init(), 
         name: String = "",
         statementDay: SKAccountStatementDay = .eom,
         created: Date = .now,
         updated: Date = .now) {
        self.uid = uid
        self.name = name
        self.statementDay = statementDay
        self.created = created
        self.updated = updated
    }
    
}
