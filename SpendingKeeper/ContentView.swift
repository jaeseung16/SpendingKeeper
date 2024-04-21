//
//  ContentView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/26/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var viewModel: SKViewModel
    //@Query private var records: [SKRecord]
    //@Query private var accounts: [SKAccount]

    @State private var selectedMenu: SKMenu? = .transactions
    @State private var selectedRecord: SKRecord?
    @State private var selectedAccount: SKAccount?
    @State private var selectedTrend: SKTrend?
    
    @State private var presentAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationSplitView {
                List(selection: $selectedMenu) {
                    ForEach(SKMenu.allCases) { menu in
                        NavigationLink(value: menu){
                            Text(menu.rawValue)
                        }
                    }
                }
            } content: {
                switch selectedMenu {
                case .transactions:
                    RecordListView(selectedRecord: $selectedRecord)
                case .accounts:
                    AccountListView(selectedAccount: $selectedAccount)
                case .trends:
                    TrendsListView(selectedTrend: $selectedTrend)
                case nil:
                    Text("Select a menu")
                }
            } detail: {
                switch selectedMenu {
                case .transactions:
                    if let record = selectedRecord {
                        RecordDetailView(record: record, account: findAccount(of: record))
                            .id(record.uid)
                    }
                case .accounts:
                    if let account = selectedAccount {
                        AccountDetailView(account: account, startDate: viewModel.latestStatementDate(account.statementDay))
                            .id(account.uid)
                            .environmentObject(viewModel)
                    }
                case .trends:
                    if let trend = selectedTrend {
                        TrendsDetailView(trend: trend, stats: viewModel.stats(for: trend))
                            .id(trend)
                            .environmentObject(viewModel)
                    }
                case nil:
                    Text("Select a menu")
                }
            }
            .navigationSplitViewStyle(.balanced)
            .alert("Can't find an account", isPresented: $presentAlert) {
                Button("Dismiss") {
                    presentAlert = false
                }
            }
        }
    }
    
    private func findAccount(of record: SKRecord) -> SKAccount? {
        var account: SKAccount?
        do {
            if let accountId = record.accountId {
                let descriptor = FetchDescriptor<SKAccount>(predicate: #Predicate {$0.uid == accountId} )
                let accounts = try modelContext.fetch(descriptor)
                account = accounts.first
            }
        } catch {
            presentAlert = true
        }
        return account
    }

}
