//
//  SKSnapshot.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/10/24.
//

import Foundation
import SwiftData

@Model
class SKSnapshot {
    
    var uuid: UUID = UUID()
    var title: String = ""
    var begin: Date = Date()
    var end: Date = Date()
    @Relationship(deleteRule: .cascade, inverse: \SKSnapshotIncome.snapshot) var incomes: [SKSnapshotIncome]?
    @Relationship(deleteRule: .cascade, inverse: \SKSnapshotSpending.snapshot) var spendings: [SKSnapshotSpending]?
    var created: Date = Date()
    var updated: Date = Date()
    
    init(uuid: UUID = .init(),
         title: String = "",
         begin: Date = .now,
         end: Date = .now,
         incomes: [SKSnapshotIncome]? = nil,
         spendings: [SKSnapshotSpending]? = nil,
         created: Date = .now,
         updated: Date = .now) {
        self.uuid = uuid
        self.title = title
        self.begin = begin
        self.end = end
        self.incomes = incomes
        self.spendings = spendings
        self.created = created
        self.updated = updated
    }
    
}
