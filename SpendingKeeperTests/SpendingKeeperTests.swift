//
//  SpendingKeeperTests.swift
//  SpendingKeeperTests
//
//  Created by Jae Seung Lee on 3/26/24.
//

import XCTest
@testable import SpendingKeeper
import SwiftData

final class SpendingKeeperTests: XCTestCase {

    @MainActor
    let testContainer: ModelContainer = {
        do {
            let container = try ModelContainer(for: SKAccount.self, SKRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            return container
        } catch {
            fatalError("Failed to create test container")
        }
    }()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor func testLatestStatementDateOne() throws {
        let viewModel = SKViewModel(modelContext: testContainer.mainContext)
        
        let actualDate = viewModel.latestStatementDate(.one)
        
        let daysToSubtract = Calendar.current.component(.day, from: .now)
        let expectedDate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1 - daysToSubtract, to: .now)!)
        
        XCTAssertEqual(actualDate, expectedDate)
    }
    
    @MainActor func testLatestStatementDateQuarterly() throws {
        let viewModel = SKViewModel(modelContext: testContainer.mainContext)
        
        let actualDate = viewModel.latestStatementDate(.quarterly)
        
        let monthNow = Calendar.current.component(.month, from: .now)
        let yearNow = Calendar.current.component(.year, from: .now)
        
        let quarter = monthNow/3 + 1
        let startMonthofQuater = (quarter - 1) * 3 + 1
        let dateComponents = DateComponents(year: yearNow, month: startMonthofQuater, day: 1)
        
        let expectedDate = Calendar.current.startOfDay(for: Calendar.current.date(from: dateComponents)!)

        XCTAssertEqual(actualDate, expectedDate)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
