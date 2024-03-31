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
    @State private var presentAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                header
                
                Divider()
                
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
        if modelContext.hasChanges {
            account.updated = .now
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
