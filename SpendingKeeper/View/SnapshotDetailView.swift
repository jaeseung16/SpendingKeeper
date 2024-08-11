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
    
    private var sumOfIncome: Double
    private var sumOfSpending: Double
    
    private let miniumPercentageToDisplayAnootation = 10.0
    
    init(snapshot: SKSnapshot) {
        self.snapshot = snapshot
        
        self.sumOfIncome = snapshot.incomes?.map { $0.total }.reduce(0.0, +) ?? 0.0
        self.sumOfSpending = snapshot.spendings?.map { $0.total }.reduce(0.0, +) ?? 0.0
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                header
                
                Divider()
                
                if let spendings = snapshot.spendings {
                    Section {
                        HStack {
                            Chart(spendings, id: \.accoundId) {
                                barMark($0.accountName, $0.total, $0.total / sumOfSpending)
                            }
                            .chartYScale(domain: [0, 1.1 * sumOfSpending])
                            
                            Chart(spendings, id: \.accoundId) {
                                sectorMark($0.accountName, $0.total, $0.total / sumOfSpending)
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
                                barMark($0.accountName, $0.total, $0.total / sumOfIncome)
                            }
                            .chartYScale(domain: [0, 1.1 * sumOfIncome])
                            
                            Chart(incomes, id: \.accoundId) {
                                sectorMark($0.accountName, $0.total, $0.total / sumOfIncome)
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
                
                Text("CREATED ON").font(.caption)
                Text(snapshot.created, format: Date.FormatStyle(date: .numeric, time: .omitted))
                
                Spacer()
            }
        }
    }
    
    private func barMark(_ accountName: String, _ total: Double, _ fraction: Double) -> some ChartContent {
        BarMark(y: .value("Total", total))
        .foregroundStyle(by: .value("Account", accountName))
        .annotation(position: .overlay) {
            if fraction * 100.0 > miniumPercentageToDisplayAnootation {
                Text(total, format: .currency(code: Locale.current.currency?.identifier ?? ""))
            }
        }
    }
    
    private func sectorMark(_ accountName: String, _ total: Double, _ fraction: Double) -> some ChartContent {
        SectorMark(angle: .value("Total", total))
            .foregroundStyle(by: .value("Account", accountName))
            .annotation(position: .overlay) {
                if fraction * 100.0 > miniumPercentageToDisplayAnootation {
                    Text(fraction, format: .percent.precision(.fractionLength(1)))
                }
            }
    }
}
