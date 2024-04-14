//
//  SKViewModel.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 4/2/24.
//

import Foundation
import os
import SwiftData

class SKViewModel: NSObject, ObservableObject {
    let logger = Logger()
    
    let calendar = Calendar.current
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func generate(trend: SKTrend, from: Date, to: Date) -> [SKStats] {
        var dates = [Date]()
        var stats = [SKStats]()
        
        var matchingDateComponents: DateComponents
        var aMonthAgo: Date?
        var aYearAgo: Date?
        var start: Date?
        var granularity: Calendar.Component
        switch trend {
        case .daily:
            matchingDateComponents = DateComponents(hour:0, minute: 0, second: 0)
            aMonthAgo = calendar.date(byAdding: .month, value: -1, to: to)
            if let aMonthAgo = aMonthAgo, let firstDayOfLastMonth = calendar.nextDate(after: aMonthAgo, matching: DateComponents(day: 1), matchingPolicy: .nextTime, direction: .backward) {
                start = calendar.date(byAdding: .day, value: -1, to: firstDayOfLastMonth)
            }
            granularity = .day
        case .monthly:
            matchingDateComponents = DateComponents(day: 1, hour:0, minute: 0, second: 0)
            aYearAgo = calendar.date(byAdding: .year, value: -1, to: to)
            if let aYearAgo = aYearAgo, let firstDayOfLastYear = calendar.nextDate(after: aYearAgo, matching: DateComponents(month: 1, day: 1), matchingPolicy: .nextTime, direction: .backward) {
                logger.log("firstDayOfLastYear=\(firstDayOfLastYear)")
                start = calendar.date(byAdding: .day, value: -1, to: firstDayOfLastYear)
            }
            granularity = .month
        case .yearly:
            matchingDateComponents = DateComponents(month: 1, day: 1, hour:0, minute: 0, second: 0)
            start = calendar.date(byAdding: .year, value: -1, to: from)
            granularity = .year
        }
        
        guard let start = start else {
            return [SKStats]()
        }
        
        calendar.enumerateDates(startingAfter: start, matching: matchingDateComponents, matchingPolicy: .nextTime) { result, exactMatch, stop in
            guard let result = result else {
                return
            }
            
            if result > to {
                stop = true
            } else {
                dates.append(result)
            }
        }
        
        logger.log("start=\(String(describing: start)), aYearAgo=\(String(describing: aYearAgo))")
        
        let records = fetchRecords(from: start, to: to)
        
        var index = 0
        for date in dates {
            var stat: SKStats
            
            if let aMonthAgo = aMonthAgo, calendar.isDate(date, equalTo: aMonthAgo, toGranularity: .month) {
                if let aMonthAfter = calendar.date(byAdding: .month, value: 1, to: date) {
                    stat = SKStats(date: aMonthAfter, value: 0.0, period: .previous)
                } else if let startOfMonth = calendar.date(bySetting: .day, value: 1, of: date),
                          let lastDayOfPreviousMonth = calendar.nextDate(after: startOfMonth, matching: DateComponents(hour:0, minute: 0, second: 0), matchingPolicy: .nextTime, direction: .backward) {
                    stat = SKStats(date: lastDayOfPreviousMonth, value: 0.0, period: .previous)
                } else {
                    stat = SKStats(date: date, value: 0.0, period: .previous)
                }
            } else if let aYearAgo = aYearAgo, calendar.isDate(date, equalTo: aYearAgo, toGranularity: .year) {
                if let aYearAfter = calendar.date(byAdding: .year, value: 1, to: date) {
                    stat = SKStats(date: aYearAfter, value: 0.0, period: .previous)
                } else {
                    stat = SKStats(date: date, value: 0.0, period: .previous)
                }
            } else {
                stat = SKStats(date: date, value: 0.0, period: .current)
            }
            
            while index < records.count && calendar.isDate(records[index].recordDate, equalTo: date, toGranularity: granularity) {
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
        
        logger.log("stats=\(stats)")
        
        return stats
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
}
