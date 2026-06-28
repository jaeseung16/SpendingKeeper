//
//  SKSnapshotChartData.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/18/24.
//

import Foundation

protocol SKSnapshotChartData {
    var accoundId: UUID { get }
    var accountName: String { get }
    var total: Double { get }
}
