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
        var currentSum = 0.0
        var previousSum = 0.0
        return stats.map { stat in
            switch stat.period {
            case .previous:
                previousSum += stat.value
                return SKStats(date: stat.date, value: previousSum, period: .previous)
            case .current:
                currentSum += stat.value
                return SKStats(date: stat.date, value: currentSum, period: .current)
            }
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
                TrendsChartView(stats: cumulativeStats, trend: trend)
            } else {
                TrendsChartView(stats: stats, trend: trend)
            }
        }
    }
}
