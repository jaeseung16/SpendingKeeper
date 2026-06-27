//
//  SettingsView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 6/27/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(SKAuthenticator.self) private var authenticator: SKAuthenticator

    var body: some View {
        @Bindable var authenticator = authenticator

        Form {
            Section {
                Toggle("Require authentication", isOn: $authenticator.isEnabled)
            } header: {
                Text("Privacy")
            } footer: {
                Text("Require Face ID, Touch ID, or your device passcode to open SpendingKeeper.")
            }
        }
    }
}
