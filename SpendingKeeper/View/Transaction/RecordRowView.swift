//
//  RecordRowView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/30/24.
//

import SwiftUI

struct RecordRowView: View {
    
    @State var record: SKRecord
    
    var body: some View {
        HStack {
            switch record.transactionType {
            case .income:
                Image(systemName: "banknote")
            case .spending:
                Image(systemName: "cart")
            }

            Text(record.recordDescription)
            
            Spacer()
            
            // TODO: - currency code
            Text(record.amount, format: .currency(code: Locale.current.currency?.identifier ?? ""))
            
            Text(record.recordDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
                .font(.caption)
            
        }
    }
}
