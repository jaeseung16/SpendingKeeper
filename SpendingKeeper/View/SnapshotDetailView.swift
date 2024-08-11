//
//  SnapshotDetailView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/10/24.
//

import SwiftUI
import Charts

struct SnapshotDetailView: View {
    @EnvironmentObject private var viewModel: SKViewModel
    
    @State var snapshot: SKSnapshot
    @State private var presentShareSheet = false
    @State private var presentAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                header
                
                Divider()
                
                if let spendings = snapshot.spendings {
                    Section {
                        HStack {
                            Chart(spendings, id: \.accoundId) {
                                barMark($0.accountName, $0.total)
                            }
                            Chart(spendings, id: \.accoundId) {
                                sectorMark($0.accountName, $0.total)
                            }
                        }
                    } header: {
                        HStack {
                            Text("SPENDING")
                                .font(.title3)
                            Spacer()
                        }
                    }
                    .padding()
                }
                
                if let incomes = snapshot.incomes {
                    Section {
                        HStack {
                            Chart(incomes, id: \.accoundId) {
                                barMark($0.accountName, $0.total)
                            }
                            Chart(incomes, id: \.accoundId) {
                                sectorMark($0.accountName, $0.total)
                            }
                        }
                    } header: {
                        HStack {
                            Text("INCOME")
                                .font(.title3)
                            Spacer()
                        }
                    }
                    .padding()
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
    
    private var header: some View {
        Group {
            Text(snapshot.title)
                .font(.title)
            
            HStack {
                Spacer()
                
                Text("FROM")
                    .font(.caption)
                Text(snapshot.begin, format: Date.FormatStyle(date: .numeric, time: .omitted))

                Text("TO")
                    .font(.caption)
                Text(snapshot.end, format: Date.FormatStyle(date: .numeric, time: .omitted))
                
                Spacer()
            }
        }
    }
    
    private func barMark(_ accountName: String, _ total: Double) -> some ChartContent {
        BarMark(y: .value("Total", total))
        .foregroundStyle(by: .value("Account", accountName))
        .annotation(position: .overlay) {
            Text(total, format: .currency(code: Locale.current.currency?.identifier ?? ""))
                .font(.caption)
        }
    }
    
    private func sectorMark(_ accountName: String, _ total: Double) -> some ChartContent {
        SectorMark(angle: .value("Total", total))
            .foregroundStyle(by: .value("Account", accountName))
            .annotation(position: .overlay) {
                Text(total, format: .currency(code: Locale.current.currency?.identifier ?? ""))
                    .font(.caption)
            }
    }
}
