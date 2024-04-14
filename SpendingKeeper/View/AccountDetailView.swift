//
//  AccountDetailView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/31/24.
//

import SwiftUI

struct AccountDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State var account: SKAccount
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                    GridRow {
                        Text("Name")
                        TextField(text: $account.name) {
                            Text("Name")
                        }
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                    }
                    
                    GridRow {
                        Text("Balance")
                        TextField("", value: $account.balance, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    GridRow {
                        Text("Date & Time")
                        DatePicker("", selection: $account.balanceDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    GridRow {
                        Text("Statement Frequency")
                        Picker("", selection: $account.statementFrequency) {
                            ForEach(SKAccountStatementFrequency.allCases) { statementFrequency in
                                Text(statementFrequency.rawValue)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Balance or Recent activities
            }
            .padding()
        }
    }
    
}
