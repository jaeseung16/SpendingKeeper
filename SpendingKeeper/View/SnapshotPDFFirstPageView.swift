//
//  SnapshotPDFView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/18/24.
//

import SwiftUI
import Charts

struct SnapshotPDFFirstPageView: View {
    
    @State var snapshot: SKSnapshot
    
    var body: some View {
        VStack {
            header
            
            Divider()
            
            if let spendings = snapshot.spendings {
                Section {
                    HStack {
                        SnapshotCharts(data: spendings)
                    }
                } header: {
                    HStack {
                        Text("SPENDING")
                            .font(.title3)
                        Spacer()
                    }
                }
                .padding()
            }
            
            if let incomes = snapshot.incomes {
                Section {
                    HStack {
                        SnapshotCharts(data: incomes)
                    }
                } header: {
                    HStack {
                        Text("INCOME")
                            .font(.title3)
                        Spacer()
                    }
                }
                .padding()
            }
        }
        .frame(width: 540.0, height: 700.0)
    }
    
    private var header: some View {
        Group {
            Text(snapshot.title)
                .font(.title)
            
            HStack {
                Spacer()
                
                Text("FROM")
                    .font(.caption)
                Text(snapshot.begin, format: Date.FormatStyle(date: .numeric, time: .omitted))

                Text("TO")
                    .font(.caption)
                Text(snapshot.end, format: Date.FormatStyle(date: .numeric, time: .omitted))
                
                Spacer()
                
                Text("CREATED ON").font(.caption)
                Text(snapshot.created, format: Date.FormatStyle(date: .numeric, time: .omitted))
                
                Spacer()
            }
        }
    }
}


