//
//  ContentView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 3/26/24.
//

import SwiftUI
import SwiftData
import AppTrackingTransparency
import GoogleMobileAds
#if canImport(FinanceKit)
import FinanceKit
#endif

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SKNavigator.self) private var navigator: SKNavigator
    @Environment(SKAuthenticator.self) private var authenticator: SKAuthenticator
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var viewModel: SKViewModel

    @State private var selectedRecord: SKRecord?
    @State private var selectedAccount: SKAccount?
    @State private var selectedSnapshot: SKSnapshot?
    
#if canImport(FinanceKit)
    @State private var selectedTransaction: FinanceKit.Transaction?
#endif
    
    @State private var presentAlert = false
    
    var body: some View {
        @Bindable var navigator = navigator
        
        GeometryReader { geometry in
            VStack {
                NavigationSplitView {
                    List(selection: $navigator.menu) {
                        ForEach(SKMenu.allCases) { menu in
                            NavigationLink(value: menu) {
                                Text(menu.rawValue)
                            }
                        }
                    }
                } content: {
                    switch navigator.menu {
                    case .transactions:
                        RecordListView(selectedRecord: $selectedRecord, cutoff: viewModel.archiveCutoffDate())
                            .navigationTitle(SKMenu.transactions.rawValue)
                    case .history:
                        HistoryListView(selectedRecord: $selectedRecord, cutoff: viewModel.archiveCutoffDate())
                            .navigationTitle(SKMenu.history.rawValue)
                    case .accounts:
                        AccountListView(selectedAccount: $selectedAccount)
                            .navigationTitle(SKMenu.accounts.rawValue)
                    case .trends:
                        TrendsListView(selectedTrend: $navigator.selectedTrend)
                            .navigationTitle(SKMenu.trends.rawValue)
                    case .snapshots:
                        SnapshotListView(selectedSnapshot: $selectedSnapshot)
                            .navigationTitle(SKMenu.snapshots.rawValue)
                    case .imports:
#if canImport(FinanceKit)
                        ImportsListView(selectedTransaction: $selectedTransaction)
                            .navigationTitle(SKMenu.imports.rawValue)
#else
                        Text("No imports available")
#endif
                    case .settings:
                        SettingsView()
                            .navigationTitle(SKMenu.settings.rawValue)
                    case nil:
                        Text("Select a menu")
                    }
                } detail: {
                    switch navigator.menu {
                    case .transactions, .history:
                        if let record = selectedRecord {
                            RecordDetailView(record: record, account: findAccount(of: record))
                                .id(record.uid)
                        }
                    case .accounts:
                        if let account = selectedAccount {
                            AccountDetailView(account: account, startDate: viewModel.latestStatementDate(account.statementDay))
                                .id(account.uid)
                        }
                    case .trends:
                        if let trend = navigator.selectedTrend {
                            TrendsDetailView(trend: trend, stats: viewModel.stats(for: trend))
                                .id(trend)
                        }
                    case .snapshots:
                        if let snapshot = selectedSnapshot {
                            SnapshotDetailView(snapshot: snapshot)
                                .id(snapshot)
                        } 
                    case .imports:
#if canImport(FinanceKit)
                        if let transaction = selectedTransaction {
                            ImportsDetailView(transaction: transaction)
                                .id(transaction.id)
                        }
#else
                        Text("No imports available")
#endif
                    case .settings:
                        Text("Select a menu")
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
                
                Spacer()
                
                #if os(iOS)
                BannerAd()
                    .frame(height: 50)
                #endif
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                ATTrackingManager.requestTrackingAuthorization { status in
                    MobileAds.shared.start(completionHandler: nil)

                }
            }
            .overlay {
                if authenticator.isEnabled {
                    if !authenticator.isUnlocked {
                        LockView { Task { await authenticator.authenticate() } }
                    } else if scenePhase != .active {
                        // Cover the content so it isn't captured in the app switcher snapshot.
                        PrivacyCover()
                    }
                }
            }
            .task {
                // Cold-launch authentication (`.onChange` does not fire for the initial phase).
                await authenticator.authenticate()
            }
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .background:
                    authenticator.lock()
                case .active:
                    if authenticator.pendingAuth {
                        authenticator.pendingAuth = false
                        Task { await authenticator.authenticate() }
                    }
                default:
                    break
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

/// Full-screen lock shown while the app is locked. The unlock button re-triggers the
/// system prompt in case the initial prompt was cancelled.
private struct LockView: View {
    let unlock: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.background)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)

                Text("SpendingKeeper is locked")
                    .font(.headline)

                Button(action: unlock) {
                    Label("Unlock", systemImage: "faceid")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

/// Opaque cover shown when the app is not active so content is hidden from the
/// app switcher snapshot.
private struct PrivacyCover: View {
    var body: some View {
        Rectangle()
            .fill(.background)
            .ignoresSafeArea()
            .overlay {
                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
            }
    }
}
