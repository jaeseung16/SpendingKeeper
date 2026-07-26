//
//  SnapshotListView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/10/24.
//

import SwiftUI
import SwiftData

struct SnapshotListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var viewModel: SKViewModel
    
    @Query(sort: \SKSnapshot.created, order: .reverse) var snapshots: [SKSnapshot]
    @Binding var selectedSnapshot: SKSnapshot?
    @State private var presentAddSnapshotView = false
    
    
    var body: some View {
        GeometryReader { geometry in
            List(selection: $selectedSnapshot) {
                ForEach(snapshots) { snapshot in
                    NavigationLink(value: snapshot) {
                        SnapshotRowView(snapshot: snapshot)
                    }
                    .id(snapshot)
                }
                .onDelete(perform: deleteRecords)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        presentAddSnapshotView = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $presentAddSnapshotView) {
                AddSnapshotView()
                    .environmentObject(viewModel)
            }
        }
    }
    
    private func deleteRecords(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(snapshots[index])
            }
        }
    }
}
