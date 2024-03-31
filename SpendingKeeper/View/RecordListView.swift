//
//  RecordListView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/30/24.
//

import SwiftUI
import SwiftData

struct RecordListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \SKRecord.recordDate, order: .reverse) var records: [SKRecord]
    @Binding var selectedRecord: SKRecord?
    @State private var presentAddRecordView = false
    
    var body: some View {
        GeometryReader { geometry in
            List(selection: $selectedRecord) {
                ForEach(records) { record in
                    NavigationLink(value: record) {
                        RecordRowView(record: record)
                    }
                    .id(record)
                }
                .onDelete(perform: deleteRecords)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        presentAddRecordView = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $presentAddRecordView) {
                AddRecordView()
            }
        }
    }
    
    private func deleteRecords(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(records[index])
            }
        }
    }
    
}

