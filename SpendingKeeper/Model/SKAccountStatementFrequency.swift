//
//  SKAccountStatementFrequency.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 4/14/24.
//

import Foundation

enum SKAccountStatementFrequency: String, CaseIterable, Identifiable, Codable {
    case monthly
    case quarterly
    case annually
    
    var id: Self { self }
}
