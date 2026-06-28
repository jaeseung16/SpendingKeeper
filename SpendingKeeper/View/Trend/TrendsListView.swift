//
//  TrendsListView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/31/24.
//

import SwiftUI

struct TrendsListView: View {
    
    @Binding var selectedTrend: SKTrend?
    
    var body: some View {
        GeometryReader { geometry in
            List(selection: $selectedTrend) {
                ForEach(SKTrend.allCases) { trend in
                    NavigationLink(value: trend) {
                        Text(trend.rawValue)
                    }
                    .id(trend)
                }
            }
        }
    }
}
