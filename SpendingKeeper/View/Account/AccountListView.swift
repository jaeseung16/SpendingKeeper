//
//  AccountListView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/30/24.
//

import SwiftUI
import SwiftData

struct AccountListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \SKAccount.name) var accounts: [SKAccount]
    @Binding var selectedAccount: SKAccount?
    @State private var presentAddAccountView = false
    
    var body: some View {
        GeometryReader { geometry in
            List(selection: $selectedAccount) {
                ForEach(accounts) { account in
                    NavigationLink(value: account) {
                        Text(account.name)
                    }
                    .id(account)
                }
                .onDelete(perform: deleteAccounts)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        presentAddAccountView = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $presentAddAccountView) {
                AddAccountView()
            }
        }
    }
    
    private func deleteAccounts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(accounts[index])
            }
        }
    }
}

