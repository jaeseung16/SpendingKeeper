//
//  AccountDetailView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/31/24.
//

import SwiftUI
import SwiftData

struct AccountDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: SKViewModel
    
    @State var account: SKAccount
    @State var startDate: Date
    @Query private var records: [SKRecord]
    
    init(account: SKAccount, startDate: Date) {
        let uid = account.uid
        
        self.account = account
        self.startDate = startDate
        self._records = Query(filter: #Predicate<SKRecord> {
            if $0.recordDate > startDate {
                if let accountId = $0.accountId {
                    return accountId == uid
                } else {
                    return false
                }
            } else {
                return false
            }
        }, sort: \SKRecord.recordDate, order: .reverse)

    }
    
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
                        Text("Statement Day")
                        Picker("", selection: $account.statementDay) {
                            ForEach(SKAccountStatementDay.allCases) { date in
                                Text(date.rawValue)
                            }
                        }
                    }
                }
                
                Spacer()

                HStack {
                    Text("Transactions since ")
                    Text(startDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
                    Spacer()
                }
                
                Table(records) {
                    TableColumn("Description", value: \.recordDescription)
                    
                    TableColumn("Date") { record in
                        Text(record.recordDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
                            .foregroundColor(.secondary)
                    }
                    
                    TableColumn("Amount") { record in
                        Text(record.amount, format: .currency(code: Locale.current.currency?.identifier ?? ""))
                            .foregroundColor(.primary)
                    }
                    .alignment(.numeric)
                }
            }
            .padding()
            .onChange(of: account.statementDay) { oldValue, newValue in
                startDate = viewModel.latestStatementDate(newValue)
            }
        }
    }
    
}
