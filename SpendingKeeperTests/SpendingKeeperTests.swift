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
        
        let quarter = (monthNow - 1)/3 + 1
        let startMonthofQuater = (quarter - 1) * 3 + 1
        let dateComponents = DateComponents(year: yearNow, month: startMonthofQuater, day: 1)
        
        let expectedDate = Calendar.current.startOfDay(for: Calendar.current.date(from: dateComponents)!)

        XCTAssertEqual(actualDate, expectedDate)
    }
    
    @MainActor func testFirstDayOfLastMonth() throws {
        let viewModel = SKViewModel(modelContext: testContainer.mainContext)
        
        let dateComponents = DateComponents(year: 2024, month: 4, day: 20)
        let dateComponentsFirstDayOfLastMonth = DateComponents(year: 2024, month: 3, day: 1)
        
        let actualDate = viewModel.firstDayOfLastMonth(from: Calendar.current.date(from: dateComponents)!)!
        let expectedDate = Calendar.current.date(from: dateComponentsFirstDayOfLastMonth)!

        XCTAssertEqual(actualDate, expectedDate)
    }
    
    @MainActor func testFirstDayOfLastYear() throws {
        let viewModel = SKViewModel(modelContext: testContainer.mainContext)
        
        let dateComponents = DateComponents(year: 2024, month: 4, day: 20)
        let dateComponentsFirstDayOfLastMonth = DateComponents(year: 2023, month: 1, day: 1)
        
        let actualDate = viewModel.firstDayOfLastYear(from: Calendar.current.date(from: dateComponents)!)!
        let expectedDate = Calendar.current.date(from: dateComponentsFirstDayOfLastMonth)!

        XCTAssertEqual(actualDate, expectedDate)
    }

    @MainActor func testArchiveCutoffDateMidYear() throws {
        let viewModel = SKViewModel(modelContext: testContainer.mainContext)

        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 7, day: 4))!
        let expectedDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!

        XCTAssertEqual(viewModel.archiveCutoffDate(from: date), expectedDate)
    }

    @MainActor func testArchiveCutoffDateOnDecember31() throws {
        let viewModel = SKViewModel(modelContext: testContainer.mainContext)

        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 12, day: 31))!
        let expectedDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!

        XCTAssertEqual(viewModel.archiveCutoffDate(from: date), expectedDate)
    }

    @MainActor func testArchiveCutoffDateOnJanuary1() throws {
        let viewModel = SKViewModel(modelContext: testContainer.mainContext)

        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 12))!
        let expectedDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!

        XCTAssertEqual(viewModel.archiveCutoffDate(from: date), expectedDate)
    }

    @MainActor func testArchiveCutoffSplitsRecords() throws {
        let context = testContainer.mainContext
        let viewModel = SKViewModel(modelContext: context)

        let now = Calendar.current.date(from: DateComponents(year: 2026, month: 7, day: 4))!
        let cutoff = viewModel.archiveCutoffDate(from: now)

        // On the cutoff (January 1 of last year): belongs to Transactions.
        let recentRecord = SKRecord(recordDate: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!,
                                    recordDescription: "recent")
        // Before the cutoff: belongs to Transaction History.
        let oldRecord = SKRecord(recordDate: Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 31))!,
                                 recordDescription: "old")
        context.insert(recentRecord)
        context.insert(oldRecord)
        defer {
            context.delete(recentRecord)
            context.delete(oldRecord)
        }

        let recentDescriptor = FetchDescriptor<SKRecord>(predicate: #Predicate { $0.recordDate >= cutoff })
        let recentUids = try context.fetch(recentDescriptor).map { $0.uid }
        XCTAssertTrue(recentUids.contains(recentRecord.uid))
        XCTAssertFalse(recentUids.contains(oldRecord.uid))

        let archivedDescriptor = FetchDescriptor<SKRecord>(predicate: #Predicate { $0.recordDate < cutoff })
        let archivedUids = try context.fetch(archivedDescriptor).map { $0.uid }
        XCTAssertTrue(archivedUids.contains(oldRecord.uid))
        XCTAssertFalse(archivedUids.contains(recentRecord.uid))
    }

    func testOneMonthLater() throws {
        let dateComponents = DateComponents(year: 2024, month: 1, day: 30)
        let dateComponentsOneMonthLater = DateComponents(year: 2024, month: 2, day: 29)
        
        let today = Calendar.current.date(from: dateComponents)!
        let oneMonthLater = Calendar.current.date(byAdding: .month, value: 1, to: today)!
        let expectedDate = Calendar.current.date(from: dateComponentsOneMonthLater)!
        
        XCTAssertEqual(oneMonthLater, expectedDate)
    }
    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
