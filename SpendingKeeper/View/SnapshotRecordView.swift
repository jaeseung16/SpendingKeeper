//
//  SKSnapshotRecordView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/17/24.
//

import SwiftUI

struct SnapshotRecordView: View {
    
    private let frameWidth = 540.0
    
    var record: SKSnapshotRecord
    
    var body: some View {
        HStack {
            Text(record.recordDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
                .frame(width: 0.2 * frameWidth)
            Text(record.accountName)
                .frame(width: 0.2 * frameWidth)
            Text(record.transactionType.rawValue)
                .frame(width: 0.2 * frameWidth)
            Text(record.recordDescription)
                .frame(width: 0.2 * frameWidth)
            Text(record.amount, format: .currency(code: Locale.current.currency?.identifier ?? ""))
                .frame(width: 0.2 * frameWidth)
        }
        .font(.caption)
        .frame(width: frameWidth)
    }
}
