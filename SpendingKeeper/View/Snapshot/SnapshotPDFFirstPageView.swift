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
            
            Divider()
            
            footer
        }
        .frame(width: 540.0, height: 700.0)
    }
    
    private var header: some View {
        Group {
            HStack {
                Text(snapshot.title)
                    .font(.title)
                Spacer()
            }
            
            HStack {
                Text("\((snapshot.begin..<snapshot.end).formatted(.interval.day().month(.wide).year()))")
                    .font(.caption)
                Spacer()
            }
        }
    }
    
    private var footer: some View {
        Group {
            HStack {
                Spacer()
                
                Text("CREATED ON")
                    .font(.caption)
                Text(snapshot.created, format: Date.FormatStyle(date: .numeric, time: .omitted))
                    .font(.caption)
            }
        }
    }
}


