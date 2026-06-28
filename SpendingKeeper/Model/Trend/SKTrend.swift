//
//  SKTrend.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/31/24.
//

import Foundation

enum SKTrend: String, CaseIterable, Identifiable, Codable {
    case daily
    case monthly
    
    var id: Self { self }
}
