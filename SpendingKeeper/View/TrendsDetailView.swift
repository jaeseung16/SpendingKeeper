//
//  TrendsDetailView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/31/24.
//

import SwiftUI
import SwiftData
import Charts

struct TrendsDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var viewModel: SKViewModel
    
    @Query(sort: \SKRecord.recordDate, order: .reverse) var records: [SKRecord]
    @Query(sort: \SKAccount.name) var accounts: [SKAccount]
    
    @State var trend: SKTrend
    
    @State private var stats = [SKStats]()
    @State private var from: Date = .now
    @State private var to: Date = .now
    
    var body: some View {
        VStack {
            Button {
                refresh()
            } label: {
                Text("Refresh")
            }
            
            HStack {
                Text("From")
                DatePicker("", selection: $from, displayedComponents: [.date])
            }
            
            HStack {
                Text("To")
                DatePicker("", selection: $to, displayedComponents: [.date])
            }
            
            Chart(stats, id: \.date) { stat in
                LineMark(x: .value("Date", stat.date, unit: unit),
                        y: .value("Count", stat.value))
                .foregroundStyle(by: .value("Month", stat.period.rawValue))
            }
            
            
            Spacer()
        }
    }
    
    private func refresh() {
        
        stats = viewModel.generate(trend: trend, from: from, to: .now)
    }
    
    private var unit: Calendar.Component {
        switch trend {
        case .daily:
            return .day
        case .monthly:
            return .month
        case .yearly:
            return .year
        }
    }
}
