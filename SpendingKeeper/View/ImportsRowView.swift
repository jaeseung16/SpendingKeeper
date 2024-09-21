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
            Text(transaction.accountID.description)
            Text(transaction.merchantName ?? "")
            Text(transaction.transactionDate.description)
            Text(transaction.transactionAmount.currencyCode)
            Text(transaction.transactionAmount.amount.formatted())
        }
    }
}
