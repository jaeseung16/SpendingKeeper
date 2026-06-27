//
//  SKAuthenticator.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 6/27/26.
//

import Foundation
import SwiftUI
import LocalAuthentication
import os

/// Abstraction over `LAContext` so the authentication logic can be unit tested
/// with a mock instead of the real biometric stack (which can't run in the simulator's XCTest).
protocol SKLAContext {
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool
}

extension LAContext: SKLAContext {}

@MainActor
@Observable
final class SKAuthenticator {
    /// UserDefaults key persisting whether the app lock is enabled.
    static let enabledKey = "localAuthEnabled"

    private static let logger = Logger(subsystem: "com.resonance.SpendingKeeper", category: "SKAuthenticator")

    /// Reason string shown in the system biometric prompt.
    private let reason = "Unlock SpendingKeeper to view your spending data."

    /// Factory producing a fresh evaluation context. A new `LAContext` is created
    /// per evaluation because a context caches a successful evaluation.
    private let contextProvider: () -> SKLAContext

    /// Whether the app content is currently visible (i.e. authentication has succeeded
    /// or is not required). Defaults to unlocked so the app is never bricked.
    var isUnlocked = true

    /// Whether the user has opted in to the biometric lock. Persisted to UserDefaults.
    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Self.enabledKey)
            // Re-lock immediately when turning the feature on.
            if isEnabled, !oldValue {
                isUnlocked = false
            }
        }
    }

    init(contextProvider: @escaping () -> SKLAContext = { LAContext() }) {
        self.contextProvider = contextProvider
        let enabled = UserDefaults.standard.bool(forKey: Self.enabledKey)
        self.isEnabled = enabled
        // Start locked only when the feature is enabled.
        self.isUnlocked = !enabled
    }

    /// Re-lock the app (e.g. when moving to the background). No-op when the lock is disabled.
    func lock() {
        guard isEnabled else { return }
        isUnlocked = false
    }

    /// Prompt for biometric / passcode authentication. Fails open if no auth method
    /// is available so the user is never permanently locked out of their own data.
    func authenticate() async {
        guard isEnabled, !isUnlocked else { return }

        let context = contextProvider()
        var policyError: NSError?

        // Biometrics with device-passcode fallback.
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &policyError) else {
            Self.logger.warning("No authentication method available, unlocking. error=\(policyError?.localizedDescription ?? "nil")")
            isUnlocked = true
            return
        }

        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            isUnlocked = success
        } catch {
            // User cancelled or authentication failed — stay locked.
            Self.logger.info("Authentication failed: \(error.localizedDescription)")
            isUnlocked = false
        }
    }
}
