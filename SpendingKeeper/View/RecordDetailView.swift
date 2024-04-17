//
//  RecordDetailView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/30/24.
//

import SwiftUI
import SwiftData

struct RecordDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \SKAccount.name) private var accounts: [SKAccount]
    
    @State var record: SKRecord
    @State var account: SKAccount?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                    GridRow {
                        Text("Income/Spending")
                        Picker("", selection: $record.transactionType) {
                            ForEach(SKTransaction.allCases) { transactionType in
                                Text(transactionType.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .gridColumnAlignment(.center)
                    }
                    
                    GridRow {
                        Text("Description")
                        TextField(text: $record.recordDescription) {
                            Text("Description")
                        }
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                    }
                    
                    GridRow {
                        Text("Amount")
                        TextField("", value: $record.amount, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    GridRow {
                        Text("Date & Time")
                        DatePicker("", selection: $record.recordDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    GridRow {
                        Text("Account")
                        Picker("", selection: $account) {
                            Text("N/A")
                                .tag(Optional<SKAccount>(nil))
                            ForEach(accounts) { account in
                                Text(account.name)
                                    .tag(Optional(account))
                            }
                        }
                    }
                    
                }
                
                Spacer()
            }
            .padding()
            .onChange(of: account) { _, newValue in
                if let account = newValue {
                    record.accountId = account.uid
                    record.accountName = account.name
                }
            }
        }
    }

}
