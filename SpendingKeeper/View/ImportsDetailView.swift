//
//  ImportsDetailView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 9/21/24.
//

import SwiftUI
import FinanceKit
import SwiftData

struct ImportsDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \SKAccount.name) private var accounts: [SKAccount]
    
    var transaction: FinanceKit.Transaction
    
    @State private var recordDate: Date
    @State private var recordDescription: String
    @State private var transactionType: SKTransaction
    @State private var amount: Double
    
    @State private var selectedAccount: SKAccount?
    @State private var imported = false
    
    init(transaction: FinanceKit.Transaction) {
        self.transaction = transaction
        self.recordDate = transaction.transactionDate
        self.recordDescription = transaction.merchantName ?? ""
        self.transactionType = .spending
        self.amount = transaction.transactionAmount.amount.primitivePlottable
    }
    
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
    
    private var header: some View {
        HStack {
            Spacer()
            
            Button {
                add()
            } label: {
                Text("Import")
            }
            .disabled(imported)
        }
    }
    
    private func add() {
        withAnimation {
            let accountName = selectedAccount?.name ?? ""
            let accountId = selectedAccount?.uid
            let amount = transaction.transactionAmount.amount.primitivePlottable
            let newRecord = SKRecord(recordDate: transaction.transactionDate,
                                     recordDescription: transaction.merchantName ?? "",
                                     transactionType: .spending,
                                     accountName: accountName,
                                     accountId: accountId,
                                     amount: amount)
            
            modelContext.insert(newRecord)
            imported = true
        }
    }
}
