//
//  SnapshotRowView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/10/24.
//

import SwiftUI

struct SnapshotRowView: View {
    
    @State var snapshot: SKSnapshot
    
    var body: some View {
        HStack {
            Text(snapshot.title)
            
            Spacer()

            Text(snapshot.begin, format: Date.FormatStyle(date: .numeric, time: .omitted))
                .font(.caption) +
            Text(" - ") +
            Text(snapshot.end, format: Date.FormatStyle(date: .numeric, time: .omitted))
                .font(.caption)
        }
    }
}
