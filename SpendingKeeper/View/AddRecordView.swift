//
//  AddRecordView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/29/24.
//

import SwiftUI
import SwiftData

struct AddRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var accounts: [SKAccount]
    
    @State var recordDate: Date = .now
    @State var recordDescription: String = ""
    @State var transactionType: SKTransaction = .spending
    @State var amount: Double = 0.0
    @State private var selectedAccount: SKAccount?
    
    var body: some View {
        VStack {
            header
            
            Divider()
            
            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    Text("Income/Spending")
                    Picker("", selection: $transactionType) {
                        ForEach(SKTransaction.allCases) { transactionType in
                            Text(transactionType.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .gridColumnAlignment(.center)
                }
                
                GridRow {
                    Text("Account")
                    Picker("", selection: $selectedAccount) {
                        Text("N/A")
                            .tag(Optional<SKAccount>(nil))
                        ForEach(accounts) { account in
                            Text(account.name)
                                .tag(Optional(account))
                        }
                    }
                }
                
                GridRow {
                    Text("Description")
                    TextField(text: $recordDescription) {
                        Text("Description")
                    }
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                }
                
                GridRow {
                    Text("Amount")
                    TextField("", value: $amount, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                }
                
                GridRow {
                    Text("Date & Time")
                    DatePicker("", selection: $recordDate, displayedComponents: [.date, .hourAndMinute])
                }
            }

        }
        .padding()
    }
    
    private func add() {
        withAnimation {
            let accountName = selectedAccount?.name ?? ""
            let accountId = selectedAccount?.uid
            let newRecord = SKRecord(recordDate: recordDate,
                                     recordDescription: recordDescription,
                                     transactionType: transactionType,
                                     accountName: accountName,
                                     accountId: accountId,
                                     amount: amount)
            
            modelContext.insert(newRecord)
            dismiss()
        }
    }
    
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
            
            Spacer()
            
            Text("Add a new transaction")
            
            Spacer()
            
            Button {
                add()
            } label: {
                Text("Save")
            }
        }
    }
    
}
