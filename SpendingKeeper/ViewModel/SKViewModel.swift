//
//  SKViewModel.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 4/2/24.
//

import Foundation
import os
import SwiftData
#if canImport(FinanceKit)
import FinanceKit
#endif

class SKViewModel: NSObject, ObservableObject {
    let logger = Logger()
    
    let calendar = Calendar.current
    let modelContext: ModelContext
    
#if canImport(FinanceKit)
    @Published var importedTransaction: FinanceKit.Transaction?
#endif
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func stats(for trend: SKTrend) -> [SKStats] {
        guard let start = calendar.date(byAdding: .day, value: -1, to: firstDateOfPreviousPeriod(for: trend)) else {
            return [SKStats]()
        }
        return stats(from: start, to: .now, trend: trend)
    }
    
    func stats(from start: Date, to end: Date, trend: SKTrend) -> [SKStats] {
        let dates = dates(from: start, to: end, trend: trend)
        let records = fetchRecords(from: start, to: end)
        
        guard !records.isEmpty else {
            return [SKStats]()
        }
        
        var stats = [SKStats]()
        var index = 0
        
        var aDateInPreviousPeriod: Date
        var previousPeriod: Calendar.Component
        var period: Calendar.Component
        switch trend {
        case .daily:
            guard let oneMonthAgo = oneMonthAgo(from: end) else {
                return [SKStats]()
            }
            aDateInPreviousPeriod = oneMonthAgo
            previousPeriod = .month
            period = .day
        case .monthly:
            guard let oneYearAgo = oneYearAgo(from: end) else {
                return [SKStats]()
            }
            aDateInPreviousPeriod = oneYearAgo
            previousPeriod = .year
            period = .month
        }
        
        for date in dates {
            var stat: SKStats
            if areDatesInTheSamePeriod(date, otherDate: aDateInPreviousPeriod, period: previousPeriod) {
                var statDate: Date
                switch trend {
                case .daily:
                    if let oneMonthLater = oneMonthLater(from: date) {
                        statDate = oneMonthLater
                    } else if let lastDayOfPreviousMonth = lastDayOfPreviousMonth(from: date) {
                        statDate = lastDayOfPreviousMonth
                    } else {
                        statDate = date
                    }
                case .monthly:
                    if let oneYearAfter = oneYearAfter(from: date) {
                        statDate = oneYearAfter
                    } else {
                        statDate = date
                    }
                }
                stat = SKStats(date: statDate, value: 0.0, period: .previous)
            } else if areDatesInTheSamePeriod(date, otherDate: end, period: previousPeriod) {
                stat = SKStats(date: date, value: 0.0, period: .current)
            } else {
                continue
            }
            
            // fast forward
            while records[index].recordDate < date {
                index += 1
            }
            
            while index < records.count && areDatesInTheSamePeriod(records[index].recordDate, otherDate: date, period: period) {
                if records[index].transactionType == .spending {
                    stat.value += records[index].amount
                }
                index += 1
            }
            
            stats.append(stat)
            
            if index >= records.count {
                break
            }
        }
        
        return stats
    }
    
    private func dates(from start: Date, to end: Date, trend: SKTrend) -> [Date] {
        var dates: [Date] = []
        
        let matchingDateComponents = switch trend {
        case .daily:
            DateComponents(hour:0, minute: 0, second: 0)
        case .monthly:
            DateComponents(day: 1, hour:0, minute: 0, second: 0)
        }
        
        calendar.enumerateDates(startingAfter: start, matching: matchingDateComponents, matchingPolicy: .nextTime) { result, exactMatch, stop in
            if let result = result {
                if result > end {
                    stop = true
                } else {
                    dates.append(result)
                }
            }
        }
        
        return dates
    }
    
    private func firstDateOfPreviousPeriod(for trend: SKTrend) -> Date {
        let start = switch trend {
        case .daily:
            firstDayOfLastMonth()
        case .monthly:
            firstDayOfLastYear()
        }
        return start ?? .now
    }
    
    func firstDayOfLastMonth(from date: Date = .now) -> Date? {
        guard let aMonthAgo = oneMonthAgo(from: date) else {
            return nil
        }
        guard let firstDayOfLastMonth = calendar.nextDate(after: aMonthAgo, matching: DateComponents(day: 1), matchingPolicy: .nextTime, direction: .backward) else {
            return nil
        }
        return firstDayOfLastMonth
    }
    
    private func oneMonthAgo(from date: Date) -> Date? {
        return calendar.date(byAdding: .month, value: -1, to: date)
    }
    
    func firstDayOfLastYear(from date: Date = .now) -> Date? {
        guard let oneYearAgo = oneYearAgo(from: date) else {
            return nil
        }
        guard let firstDayOfLastYear = calendar.nextDate(after: oneYearAgo, matching: DateComponents(month: 1, day: 1), matchingPolicy: .nextTime, direction: .backward) else {
            return nil
        }
        return firstDayOfLastYear
    }
    
    private func oneYearAgo(from date: Date) -> Date? {
        return calendar.date(byAdding: .year, value: -1, to: date)
    }
    
    private func fetchRecords(from: Date, to: Date) -> [SKRecord] {
        var records = [SKRecord]()
        do {
            let descriptor = FetchDescriptor<SKRecord>(
                predicate: #Predicate { $0.recordDate >= from && $0.recordDate <= to },
                sortBy: [SortDescriptor(\.recordDate)]
            )
            let fetchedRecords = try modelContext.fetch(descriptor)
            records.append(contentsOf: fetchedRecords)
        } catch {
            logger.log("Fetch failed")
        }
        return records
    }
    
    private func areDatesInTheSamePeriod(_ date: Date, otherDate: Date, period: Calendar.Component) -> Bool {
        return calendar.isDate(date, equalTo: otherDate, toGranularity: period)
    }
    
    private func oneMonthLater(from date: Date) -> Date? {
        return calendar.date(byAdding: .month, value: 1, to: date)
    }
    
    private func lastDayOfPreviousMonth(from date: Date) -> Date? {
        guard let startOfMonth = startOfMonth(from: date) else {
            return nil
        }
        return calendar.nextDate(after: startOfMonth, matching: DateComponents(hour:0, minute: 0, second: 0), matchingPolicy: .nextTime, direction: .backward)
    }
    
    private func startOfMonth(from date: Date) -> Date? {
        return calendar.date(bySetting: .day, value: 1, of: date)
    }
    
    private func oneYearAfter(from date: Date) -> Date? {
        return calendar.date(byAdding: .year, value: 1, to: date)
    }
    
    func latestStatementDate(_ statementDay: SKAccountStatementDay) -> Date {
        let matchingDateComponents = statementDay.convertToInt() > 0 ? dateComponents(matching: statementDay.convertToInt()) : dateComponentsMatchingFirstDayOfQuater(for: Calendar.current.component(.month, from: .now))
        return Calendar.current.nextDate(after: .now, matching: matchingDateComponents, matchingPolicy: .nextTime, direction: .backward)!
    }
    
    private func dateComponents(matching day: Int) -> DateComponents {
        return DateComponents(day: day, hour: 0, minute: 0, second: 0)
    }
    
    private func dateComponentsMatchingFirstDayOfQuater(for month: Int) -> DateComponents {
        let firstMonthOfQuater = ((month - 1) / 3) * 3 + 1
        return DateComponents(month: firstMonthOfQuater, day: 1, hour: 0, minute: 0, second: 0)
    }
    
    // Snapshot
    
    func generateSnapshot(title: String, from begin: Date, to end: Date) -> SKSnapshot {
        let records = fetchRecords(from: begin, to: end)
        let accountsByUid = fetchAllAccountsByUid()
        
        var incomes = [UUID: SKSnapshotIncome]()
        var spendings = [UUID: SKSnapshotSpending]()
        var snapshotRecords = [SKSnapshotRecord]()
        for record in records {
            guard let accountId = record.accountId else {
                continue
            }
            let accountName = accountsByUid[accountId]?.name ?? record.accountName
            switch record.transactionType {
            case .income:
                accumulateIncome(&incomes, accountId: accountId, accountName: accountName, amount: record.amount)
            case .spending:
                accumulateSpending(&spendings, accountId: accountId, accountName: accountName, amount: record.amount)
            }
            
            snapshotRecords.append(snapshotRecord(from: record))
        }
        
        return SKSnapshot(title: title,
                          begin: begin,
                          end: end,
                          records: snapshotRecords,
                          incomes: Array(incomes.values),
                          spendings: Array(spendings.values))
    }
    
    /// Fetch all SKAccount objects and return a dictionary keyed by their uid
    private func fetchAllAccountsByUid() -> [UUID: SKAccount] {
        var map: [UUID: SKAccount] = [:]
        do {
            let descriptor = FetchDescriptor<SKAccount>(predicate: nil, sortBy: [])
            let accounts = try modelContext.fetch(descriptor)
            accounts.forEach { map[$0.uid] = $0 }
        } catch {
            logger.log("Fetch all accounts failed: \(error.localizedDescription)")
        }
        return map
    }
    
    private func snapshotRecord(from record: SKRecord) -> SKSnapshotRecord {
        return SKSnapshotRecord(recordDate: record.recordDate,
                                recordDescription: record.recordDescription,
                                transactionType: record.transactionType,
                                accountName: record.accountName,
                                amount: record.amount)
    }
    
    private func accumulateIncome(_ map: inout [UUID: SKSnapshotIncome], accountId: UUID, accountName: String, amount: Double) {
        let current = map[accountId, default: SKSnapshotIncome(accoundId: accountId, accountName: accountName, total: 0.0)]
        map[accountId] = SKSnapshotIncome(accoundId: current.accoundId,
                                          accountName: current.accountName,
                                          total: current.total + amount)
    }

    private func accumulateSpending(_ map: inout [UUID: SKSnapshotSpending], accountId: UUID, accountName: String, amount: Double) {
        let current = map[accountId, default: SKSnapshotSpending(accoundId: accountId, accountName: accountName, total: 0.0)]
        map[accountId] = SKSnapshotSpending(accoundId: current.accoundId,
                                            accountName: current.accountName,
                                            total: current.total + amount)
    }
    
    func generateCSV(from start: Date, to end: Date) -> URL? {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let filename = "SpendingKeeper_\(start)_\(end).csv"
        let csvFileURL = path.appendingPathComponent(filename)
        let csvString = buildCSV(records: fetchRecords(from: start, to: end))
        do {
            try csvString.write(to: csvFileURL, atomically: true, encoding: .utf8)
        } catch {
            logger.log("Failed to save the csv file \(filename): \(error.localizedDescription)")
        }
        
        logger.log("Generated CSV file at \(csvFileURL)")
        return csvFileURL
    }
    
    private func buildCSV(records: [SKRecord]) -> String {
        var csvString = "Date, Description, Income, Spending, Account\n"
        
        for record in records {
            csvString += "\(record.recordDate), "
            csvString += "\(record.recordDescription), "
            
            if record.transactionType == .income {
                csvString += "\(record.amount), , "
            } else {
                csvString += ", \(record.amount), "
            }
            
            csvString += "\(record.accountName)\n"
        }
        
        return csvString
    }
}

