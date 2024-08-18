//
//  SnapshotCharts.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/18/24.
//

import SwiftUI
import Charts

struct SnapshotCharts: View {
    
    private let miniumPercentageToDisplayAnootation = 10.0
    
    @State var data: [SKSnapshotChartData]
    
    private var sumOfTotal: Double {
        data.map { $0.total }.reduce(0.0, +)
    }
    
    var body: some View {
        HStack {
            Chart(data, id: \.accoundId) {
                barMark($0.accountName, $0.total, $0.total / sumOfTotal)
            }
            .chartYScale(domain: [0, 1.1 * sumOfTotal])
            
            Chart(data, id: \.accoundId) {
                sectorMark($0.accountName, $0.total, $0.total / sumOfTotal)
            }
        }
    }
    
    private func barMark(_ accountName: String, _ total: Double, _ fraction: Double) -> some ChartContent {
        BarMark(y: .value("Total", total))
        .foregroundStyle(by: .value("Account", accountName))
        .annotation(position: .overlay) {
            if fraction * 100.0 > miniumPercentageToDisplayAnootation {
                Text(total, format: .currency(code: Locale.current.currency?.identifier ?? ""))
                    .font(.callout)
            }
        }
    }
    
    private func sectorMark(_ accountName: String, _ total: Double, _ fraction: Double) -> some ChartContent {
        SectorMark(angle: .value("Total", total))
            .foregroundStyle(by: .value("Account", accountName))
            .annotation(position: .overlay) {
                if fraction * 100.0 > miniumPercentageToDisplayAnootation {
                    Text(fraction, format: .percent.precision(.fractionLength(0)))
                        .font(.callout)
                }
            }
    }
}
