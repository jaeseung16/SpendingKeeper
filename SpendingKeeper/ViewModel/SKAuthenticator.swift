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

    /// Store backing the persisted `isEnabled` flag. Injectable for testing.
    private let defaults: UserDefaults

    /// Whether the app content is currently visible (i.e. authentication has succeeded
    /// or is not required). Defaults to unlocked so the app is never bricked.
    var isUnlocked = true

    /// Set when the app is backgrounded, consumed on the next foreground to decide
    /// whether to re-prompt. This avoids re-firing the prompt on transient
    /// `.inactive → .active` cycles caused by the system auth UI itself.
    var pendingAuth = false

    /// Guards against overlapping evaluations (e.g. `.task` and a scenePhase change
    /// both firing before the first prompt resolves).
    private var isAuthenticating = false

    /// Whether the user has opted in to the biometric lock. Persisted to UserDefaults.
    var isEnabled: Bool {
        didSet {
            defaults.set(isEnabled, forKey: Self.enabledKey)
            // Re-lock immediately when turning the feature on.
            if isEnabled, !oldValue {
                isUnlocked = false
            }
        }
    }

    init(contextProvider: @escaping () -> SKLAContext = { LAContext() },
         defaults: UserDefaults = .standard) {
        self.contextProvider = contextProvider
        self.defaults = defaults
        let enabled = defaults.bool(forKey: Self.enabledKey)
        self.isEnabled = enabled
        // Start locked only when the feature is enabled.
        self.isUnlocked = !enabled
    }

    /// Re-lock the app (e.g. when moving to the background) and mark that a prompt is
    /// owed on the next foreground. No-op when the lock is disabled.
    func lock() {
        guard isEnabled else { return }
        isUnlocked = false
        pendingAuth = true
    }

    /// Prompt for biometric / passcode authentication. Fails open if no auth method
    /// is available so the user is never permanently locked out of their own data.
    func authenticate() async {
        guard isEnabled, !isUnlocked, !isAuthenticating else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }

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
