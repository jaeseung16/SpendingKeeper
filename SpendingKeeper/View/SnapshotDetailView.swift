//
//  SnapshotDetailView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/10/24.
//

import SwiftUI

struct SnapshotDetailView: View {
    @EnvironmentObject private var viewModel: SKViewModel
    
    @State var snapshot: SKSnapshot
    @State private var presentShareSheet = false
    @State private var presentAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(snapshot.title)
                
                Text(snapshot.begin, format: Date.FormatStyle(date: .numeric, time: .omitted))
                    .font(.caption)
                
                Text(snapshot.end, format: Date.FormatStyle(date: .numeric, time: .omitted))
                    .font(.caption)
                
                if let incomes = snapshot.incomes {
                    List {
                        ForEach(incomes) { income in
                            Text("\(income.accountName): \(income.total)")
                        }
                    }
                }
                
                if let spendings = snapshot.spendings {
                    List {
                        ForEach(spendings) { spending in
                            Text("\(spending.accountName): \(spending.total)")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        presentShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $presentShareSheet) {
                if let url = viewModel.generateCSV(from: Date(), to: Date()) {
                    ShareActivityView(url: url, applicationActivities: nil, failedToRemoveItem: $presentAlert)
                }
            }
            .alert("Failed to remove files", isPresented: $presentAlert) {
                Button("Dismiss") {
                    presentAlert = false
                }
            }
                
        }
        
    }
}
