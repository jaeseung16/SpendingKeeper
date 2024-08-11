//
//  AddSnapshotView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/10/24.
//

import SwiftUI

struct AddSnapshotView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var viewModel: SKViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var begin: Date = .now
    @State private var end: Date = .now
    @State private var title = ""
    
    var body: some View {
        VStack {
            header
            
            Divider()
            
            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    Text("Title")
                    TextField(text: $title) {
                        Text("Title")
                    }
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                }
                
                GridRow {
                    Text("Start Date")
                    DatePicker("", selection: $begin, displayedComponents: [.date])
                }
                
                GridRow {
                    Text("End Date")
                    DatePicker("", selection: $end, displayedComponents: [.date])
                }
            }
        }
        .padding()
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
                add()
            } label: {
                Text("Save")
            }
        }
    }
    
    private func add() {
        withAnimation {
            let (incomes, spendings) = viewModel.totalByAccount(from: begin, to: end)
            let newRecord = SKSnapshot(title: title,
                                       begin: begin,
                                       end: end,
                                       incomes: incomes,
                                       spendings: spendings)
            
            modelContext.insert(newRecord)
            dismiss()
        }
    }
}