//
//  ImportsListView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 9/21/24.
//

import SwiftUI
import FinanceKit
import FinanceKitUI

struct ImportsListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var selectedTransaction: FinanceKit.Transaction?
    
    @State private var transactions: [FinanceKit.Transaction] = []
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if transactions.isEmpty {
                    HStack {
                        Spacer()
                        
                        TransactionPicker(selection: $transactions) {
                            Label {
                                Text("Select Transactions")
                            } icon: {
                                Image(systemName: "creditcard")
                            }
                        }
                        
                        Spacer()
                    }
                } else {
                    List(selection: $selectedTransaction) {
                        ForEach(transactions) { transaction in
                            NavigationLink(value: transaction) {
                                ImportsRowView(transaction: transaction)
                            }
                            .id(transaction.id)
                        }
                    }
                }
            }
        }
    }
}

extension FinanceKit.Transaction: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
