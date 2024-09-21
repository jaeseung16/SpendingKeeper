//
//  ImportsRowView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 9/21/24.
//

import SwiftUI
import FinanceKit

struct ImportsRowView: View {
    
    @State var transaction: FinanceKit.Transaction
    
    var body: some View {
        VStack {
            HStack {
                switch transaction.creditDebitIndicator {
                case .credit:
                    Image(systemName: "banknote")
                case .debit:
                    Image(systemName: "cart")
                @unknown default:
                    EmptyView()
                }
                
                Text(transaction.transactionDescription)
                
                Spacer()
            }
            
            HStack {
                Text(transaction.transactionAmount.currencyCode)
                Text(transaction.transactionAmount.amount.formatted())
                
                Spacer()
                
                Text(transaction.transactionDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
                    .font(.caption)
            }
        }
    }
}
