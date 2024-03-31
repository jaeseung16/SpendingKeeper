//
//  AccountRowView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/31/24.
//

import SwiftUI

struct AccountRowView: View {
    
    @State var account: SKAccount
    
    var body: some View {
        HStack {
            Text(account.name)

            Spacer()
            
            Text(account.balance, format: .number)
            
            Text(account.balanceDate, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
        }
    }
}
