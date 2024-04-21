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
    @State var stats = [SKStats]()
    @State private var cumulative = false
    
    private var cumulativeStats: [SKStats] {
        var previousSum = 0.0
        var currentSum = 0.0
        return stats.map { stat in
            var cumulativeStat: SKStats
            if stat.period == .previous {
                previousSum += stat.value
                cumulativeStat = SKStats(date: stat.date, value: previousSum, period: .previous)
            } else {
                currentSum += stat.value
                cumulativeStat = SKStats(date: stat.date, value: currentSum, period: .current)
            }
            return cumulativeStat
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                switch trend {
                case .daily:
                    Text("This Month vs. Last Month")
                case .monthly:
                    Text("This Year vs. Last Year")
                }
                
                Spacer()
                
                Toggle(isOn: $cumulative) {
                    Text("cumulative")
                }
                .toggleStyle(.button)
            }
            
            if (cumulative) {
                Chart(cumulativeStats, id: \.date) { stat in
                    LineMark(x: .value("Date", stat.date, unit: unit),
                            y: .value("Count", stat.value))
                    .foregroundStyle(by: .value("Month", stat.period.rawValue))
                    .interpolationMethod(.stepCenter)
                }
            } else {
                Chart(stats, id: \.date) { stat in
                    LineMark(x: .value("Date", stat.date, unit: unit),
                            y: .value("Count", stat.value))
                    .foregroundStyle(by: .value("Month", stat.period.rawValue))
                    .interpolationMethod(.stepCenter)
                }
            }
        }
    }
    
    private var unit: Calendar.Component {
        switch trend {
        case .daily:
            return .day
        case .monthly:
            return .month
        }
    }
}
