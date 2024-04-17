//
//  AddAccountView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/29/24.
//

import SwiftUI

struct AddAccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var balance: Double = 0.0
    @State private var balanceDate: Date = .now
    @State private var statementDate: SKAccountStatementDate = .eom
    
    var body: some View {
        VStack {
            header
            
            Divider()
            
            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    Text("Name")
                    TextField(text: $name) {
                        Text("Name")
                    }
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .gridColumnAlignment(.center)
                }
                
                GridRow {
                    Text("Statement Date")
                    Picker("", selection: $statementDate) {
                        ForEach(SKAccountStatementDate.allCases) { statementDate in
                            Text(statementDate.rawValue)
                        }
                    }
                }

            }
        }
        .padding()
    }
    
    private func add() {
        withAnimation {
            let newAccount = SKAccount(name: name, statementDate: statementDate)
            modelContext.insert(newAccount)
            dismiss()
        }
    }
    
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
            
            Spacer()
            
            Text("Add a new account")
            
            Spacer()
            
            Button {
                add()
            } label: {
                Text("Save")
            }
        }
    }
    
}
