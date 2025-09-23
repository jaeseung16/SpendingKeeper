//
//  SKNavigationOption.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 9/21/25.
//

import AppIntents
import SwiftUI

enum NavigationOption: String, Hashable, Identifiable, CaseIterable, AppEnum {
    
    case addTransaction
    
    static let caseDisplayRepresentations: [NavigationOption : DisplayRepresentation] = [
        .addTransaction: DisplayRepresentation(title: "Add a new transaction"),
    ]
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        return TypeDisplayRepresentation(
            name: LocalizedStringResource("Navigation Option", table: "AppIntents"),
            numericFormat: "\(placeholder: .int) navigation options"
        )
    }
    
    var id: String { rawValue }
    
}
