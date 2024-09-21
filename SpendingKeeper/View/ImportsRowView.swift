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
            Text(transaction.merchantName ?? "")
            Text(transaction.transactionDescription)
            Text("\(transaction.creditDebitIndicator.rawValue)")
            
            HStack {
                Text(transaction.transactionAmount.currencyCode)
                Text(transaction.transactionAmount.amount.formatted())
                //Text(record.amount, format: .currency(code: Locale.current.currency?.identifier ?? ""))
                
                Spacer()
                
                Text(transaction.transactionDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
                    .font(.caption)
            }
        }
    }
}
