//
//  SwiftUIView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 9/21/24.
//

import SwiftUI
import SwiftData
import FinanceKit
import FinanceKitUI

struct ImportTransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \SKAccount.name) private var accounts: [SKAccount]
    
    @State private var selectedTransactions: [FinanceKit.Transaction] = []
    @State private var selectedAccount: SKAccount?
    
    var body: some View {
        if #available(iOS 18, *) {
            VStack {
                TransactionPicker(selection: $selectedTransactions) {
                    Label {
                        Text("Select Transactions")
                    } icon: {
                        Image(systemName: "creditcard")
                    }
                }
                
                if !selectedTransactions.isEmpty {
                    List {
                        ForEach(selectedTransactions) {
                            transactionRow(transaction: $0)
                        }
                    }
                }
            }
        } else {
                    EmptyView()
        }
    }
    
    private func transactionRow(transaction: FinanceKit.Transaction) -> some View {
        VStack {
            Text(transaction.accountID.description)
            Text(transaction.merchantName ?? "")
            Text(transaction.transactionDate.description)
            Text(transaction.transactionAmount.currencyCode)
            Text(transaction.transactionAmount.amount.formatted())
            
            Picker("", selection: $selectedAccount) {
                Text("N/A")
                    .tag(Optional<SKAccount>(nil))
                ForEach(accounts) { account in
                    Text(account.name)
                        .tag(Optional(account))
                }
            }
            
            Button {
                add(transaction: transaction)
            } label: {
                Text("Import")
            }

        }
    }
    
    private func add(transaction: FinanceKit.Transaction) {
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
            dismiss()
        }
    }
}
