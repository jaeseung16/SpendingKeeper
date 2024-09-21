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
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
    #else
    private let isCompact = false
    #endif
    
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
                    TableColumn("Description") {
                        firstColumn($0)
                    }
                    
                    TableColumn("Date") {
                        Text($0.recordDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
                            .foregroundColor(.secondary)
                    }
                    
                    TableColumn("Amount") {
                        Text($0.amount, format: .currency(code: Locale.current.currency?.identifier ?? ""))
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
    
    private func firstColumn(_ record: SKRecord) -> some View {
        VStack(alignment: .leading) {
            if isCompact {
                Text(record.recordDescription)
                HStack {
                    Text(record.amount, format: .currency(code: Locale.current.currency?.identifier ?? ""))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(record.recordDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
                        .foregroundColor(.secondary)
                }
            } else {
                Text(record.recordDescription)
                    .foregroundColor(.secondary)
            }
        }
    }
    
}
