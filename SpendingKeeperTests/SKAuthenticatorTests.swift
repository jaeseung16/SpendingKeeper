//
//  SKAuthenticatorTests.swift
//  SpendingKeeperTests
//
//  Created by Jae Seung Lee on 6/27/26.
//

import XCTest
import LocalAuthentication
@testable import SpendingKeeper

/// Test double for `SKLAContext` so authentication logic can be exercised without
/// the real biometric stack (which can't run in the simulator's XCTest).
private final class MockLAContext: SKLAContext {
    var canEvaluate: Bool
    var evaluateResult: Result<Bool, Error>
    private(set) var evaluateCallCount = 0

    init(canEvaluate: Bool = true, evaluateResult: Result<Bool, Error> = .success(true)) {
        self.canEvaluate = canEvaluate
        self.evaluateResult = evaluateResult
    }

    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        if !canEvaluate {
            error?.pointee = NSError(domain: LAErrorDomain, code: LAError.biometryNotAvailable.rawValue)
        }
        return canEvaluate
    }

    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool {
        evaluateCallCount += 1
        switch evaluateResult {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}

@MainActor
final class SKAuthenticatorTests: XCTestCase {

    /// A throwaway, isolated defaults suite so tests never touch the real store.
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUpWithError() throws {
        suiteName = "SKAuthenticatorTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
    }

    private func makeAuthenticator(enabled: Bool = false,
                                   context: MockLAContext = MockLAContext()) -> SKAuthenticator {
        defaults.set(enabled, forKey: SKAuthenticator.enabledKey)
        return SKAuthenticator(contextProvider: { context }, defaults: defaults)
    }

    // MARK: - Initial state

    func testDisabledStartsUnlocked() {
        let auth = makeAuthenticator(enabled: false)
        XCTAssertFalse(auth.isEnabled)
        XCTAssertTrue(auth.isUnlocked)
    }

    func testEnabledStartsLocked() {
        let auth = makeAuthenticator(enabled: true)
        XCTAssertTrue(auth.isEnabled)
        XCTAssertFalse(auth.isUnlocked)
    }

    // MARK: - authenticate()

    func testAuthenticateSuccessUnlocks() async {
        let context = MockLAContext(evaluateResult: .success(true))
        let auth = makeAuthenticator(enabled: true, context: context)

        await auth.authenticate()

        XCTAssertTrue(auth.isUnlocked)
        XCTAssertEqual(context.evaluateCallCount, 1)
    }

    func testAuthenticateFailureStaysLocked() async {
        let context = MockLAContext(evaluateResult: .failure(LAError(.authenticationFailed)))
        let auth = makeAuthenticator(enabled: true, context: context)

        await auth.authenticate()

        XCTAssertFalse(auth.isUnlocked)
    }

    func testAuthenticateCancelStaysLocked() async {
        let context = MockLAContext(evaluateResult: .failure(LAError(.userCancel)))
        let auth = makeAuthenticator(enabled: true, context: context)

        await auth.authenticate()

        XCTAssertFalse(auth.isUnlocked)
    }

    /// Fail open: if no authentication method is available, the user must not be
    /// permanently locked out of their own data.
    func testFailsOpenWhenPolicyUnavailable() async {
        let context = MockLAContext(canEvaluate: false)
        let auth = makeAuthenticator(enabled: true, context: context)

        await auth.authenticate()

        XCTAssertTrue(auth.isUnlocked)
        XCTAssertEqual(context.evaluateCallCount, 0, "Should not evaluate when no policy is available")
    }

    func testAuthenticateNoOpWhenDisabled() async {
        let context = MockLAContext(evaluateResult: .success(true))
        let auth = makeAuthenticator(enabled: false, context: context)

        await auth.authenticate()

        XCTAssertEqual(context.evaluateCallCount, 0, "Should not prompt when the lock is disabled")
        XCTAssertTrue(auth.isUnlocked)
    }

    func testAuthenticateNoOpWhenAlreadyUnlocked() async {
        let context = MockLAContext(evaluateResult: .success(true))
        let auth = makeAuthenticator(enabled: false, context: context) // starts unlocked

        await auth.authenticate()

        XCTAssertEqual(context.evaluateCallCount, 0)
    }

    // MARK: - lock()

    func testLockRelocksAndSetsPendingAuth() {
        let auth = makeAuthenticator(enabled: true)
        auth.isUnlocked = true

        auth.lock()

        XCTAssertFalse(auth.isUnlocked)
        XCTAssertTrue(auth.pendingAuth)
    }

    func testLockNoOpWhenDisabled() {
        let auth = makeAuthenticator(enabled: false)
        XCTAssertTrue(auth.isUnlocked)

        auth.lock()

        XCTAssertTrue(auth.isUnlocked)
        XCTAssertFalse(auth.pendingAuth)
    }

    // MARK: - isEnabled toggle

    func testEnablingRelocks() {
        let auth = makeAuthenticator(enabled: false)
        XCTAssertTrue(auth.isUnlocked)

        auth.isEnabled = true

        XCTAssertFalse(auth.isUnlocked)
        XCTAssertTrue(defaults.bool(forKey: SKAuthenticator.enabledKey), "Enabling should persist")
    }

    func testDisablingPersists() {
        let auth = makeAuthenticator(enabled: true)

        auth.isEnabled = false

        XCTAssertFalse(defaults.bool(forKey: SKAuthenticator.enabledKey))
    }
}
