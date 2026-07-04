//
//  HistoryListView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 7/4/26.
//

import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query var records: [SKRecord]
    @Binding var selectedRecord: SKRecord?

    init(selectedRecord: Binding<SKRecord?>, cutoff: Date) {
        _selectedRecord = selectedRecord
        _records = Query(filter: #Predicate<SKRecord> { $0.recordDate < cutoff },
                         sort: \SKRecord.recordDate,
                         order: .reverse)
    }

    private var recordsByYear: [(year: Int, records: [SKRecord])] {
        Dictionary(grouping: records) { Calendar.current.component(.year, from: $0.recordDate) }
            .sorted { $0.key > $1.key }
            .map { (year: $0.key, records: $0.value) }
    }

    var body: some View {
        List(selection: $selectedRecord) {
            ForEach(recordsByYear, id: \.year) { group in
                Section(String(group.year)) {
                    ForEach(group.records) { record in
                        NavigationLink(value: record) {
                            RecordRowView(record: record)
                        }
                        .id(record)
                    }
                    .onDelete { offsets in
                        deleteRecords(group.records, offsets: offsets)
                    }
                }
            }
        }
        .overlay {
            if records.isEmpty {
                ContentUnavailableView("No Past Transactions",
                                       systemImage: "clock.arrow.circlepath",
                                       description: Text("Transactions older than last year will appear here."))
            }
        }
    }

    private func deleteRecords(_ records: [SKRecord], offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(records[index])
            }
        }
    }

}
