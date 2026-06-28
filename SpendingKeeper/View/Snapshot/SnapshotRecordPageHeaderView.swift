//
//  SnapshotRecordPageHeaderView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/18/24.
//

import SwiftUI

struct SnapshotRecordPageHeaderView: View {
    private let frameWidth = 540.0
    
    var body: some View {
        VStack {
            HStack {
                Text("Date")
                    .frame(width: 0.2 * frameWidth)
                Text("Account")
                    .frame(width: 0.2 * frameWidth)
                Text("Income/Spending")
                    .frame(width: 0.2 * frameWidth)
                    .multilineTextAlignment(.center)
                Text("Description")
                    .frame(width: 0.2 * frameWidth)
                Text("Amount")
                    .frame(width: 0.2 * frameWidth)
            }
            .font(.caption)
            .bold()
            
            Divider()
        }
        .frame(width: frameWidth)
    }
}
