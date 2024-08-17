//
//  SKSnapshotRecordView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/17/24.
//

import SwiftUI

struct SnapshotRecordView: View {
    
    var record: SKSnapshotRecord
    
    var body: some View {
        HStack {
            Text(record.recordDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
                .frame(width: 108)
            Text(record.accountName)
                .frame(width: 108)
            Text(record.transactionType.rawValue)
                .frame(width: 108)
            Text(record.recordDescription)
                .frame(width: 108)
            Text(record.amount, format: .currency(code: Locale.current.currency?.identifier ?? ""))
                .frame(width: 108)
        }
        .frame(width: 540)
    }
}
