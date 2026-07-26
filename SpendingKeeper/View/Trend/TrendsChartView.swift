//
//  TrendsChartView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/8/24.
//

import SwiftUI
import Charts

struct TrendsChartView: View {
    
    @State var stats: [SKStats]
    @State var trend: SKTrend
    
    private var maxStats: [SKPeriod: SKStats] {
        stats.reduce(into: [:]) { partialResult, stat in
            let currentMax = partialResult[stat.period]
            if currentMax == nil || currentMax!.value <= stat.value {
                partialResult[stat.period] = stat
            }
        }
    }
    
    private var maxValue: Double {
        1.1 * (stats.map { $0.value }.max() ?? 100)
    }
    
    var body: some View {
        Chart() {
            ForEach(stats, id: \.date) { stat in
                LineMark(x: .value("Date", stat.date, unit: unit),
                         y: .value("Count", stat.value))
                .foregroundStyle(by: .value("Month", stat.period.rawValue))
                .interpolationMethod(.stepCenter)
            }
            
            ForEach(Array(maxStats.values), id: \.date) { stat in
                PointMark(x: .value("Date", stat.date, unit: unit),
                          y: .value("Count", stat.value))
                .foregroundStyle(Color.clear)
                .annotation(position: .top, alignment: .trailing) {
                    annotationView(stat)
                }
            }
        }
        .chartYScale(domain: [0, maxValue])
    }
    
    private var unit: Calendar.Component {
        switch trend {
        case .daily:
            return .day
        case .monthly:
            return .month
        }
    }
    
    private func annotationView(_ stats: SKStats) -> Text {
        Text(stats.value, format: .currency(code: Locale.current.currency?.identifier ?? ""))
    }
}
