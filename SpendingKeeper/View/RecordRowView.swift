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

            Text(record.recordDate, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
            
            Spacer()
            
            Text(record.amount, format: .number)
        }
    }
}
