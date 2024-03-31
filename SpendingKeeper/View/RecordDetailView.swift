//
//  RecordDetailView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/30/24.
//

import SwiftUI
import SwiftData

struct RecordDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var accounts: [SKAccount]
    
    @State var record: SKRecord
    @State var account: SKAccount?
    @State private var presentAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                header
                
                Divider()
                
                Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                    GridRow {
                        Text("Income/Spending")
                        Picker("", selection: $record.transactionType) {
                            ForEach(SKTransaction.allCases) { transactionType in
                                Text(transactionType.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .gridColumnAlignment(.center)
                    }
                    
                    GridRow {
                        Text("Account")
                        Picker("", selection: $account) {
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
                        TextField(text: $record.recordDescription) {
                            Text("Description")
                        }
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                    }
                    
                    GridRow {
                        Text("Amount")
                        TextField("", value: $record.amount, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    GridRow {
                        Text("Date & Time")
                        DatePicker("", selection: $record.recordDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Spacer()
            }
            .padding()
            .alert("Save failed", isPresented: $presentAlert) {
                Button("Dismiss") {
                    presentAlert = false
                }
            }
        }
    }
    
    private func update() {
        if let account = account {
            if account.uid != record.accountId {
                record.accountId = account.uid
            }
            
            if account.name != record.accountName {
                record.accountName = account.name
            }
        }
        
        if modelContext.hasChanges {
            record.updated = .now
            do {
                try modelContext.save()
            } catch {
                presentAlert = true
            }
        }
        
        dismiss()
    }
    
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
            
            Spacer()
            
            Text("Add a new transaction")
            
            Spacer()
            
            Button {
                update()
            } label: {
                Text("Save")
            }
        }
    }
}
