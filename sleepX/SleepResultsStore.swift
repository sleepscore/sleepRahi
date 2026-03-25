//
//  SleepResultsStore.swift
//  sleepX
//
//  Stores previously-calculated sleep results by date.
//  This intentionally does NOT run any sleep equations when displaying results.
//

import SwiftUI
import Combine

struct SavedSleepMetrics: Equatable {
    var score: Int
    var timeAsleepSeconds: TimeInterval
    var timeInBedSeconds: TimeInterval
}

final class SleepResultsStore: ObservableObject {
    static let shared = SleepResultsStore()

    let objectWillChange = ObservableObjectPublisher()

    @Published private(set) var savedByDateKey: [String: SavedSleepMetrics] = [:]

    private init() {
        seedSampleData()
    }

    private func dateKey(for date: Date) -> String {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        // yyyy-MM-dd (stable for dictionary keys)
        return String(format: "%04d-%02d-%02d",
                      comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
    }

    func metrics(for date: Date) -> SavedSleepMetrics? {
        savedByDateKey[dateKey(for: date)]
    }

    func save(metrics: SavedSleepMetrics, for date: Date) {
        savedByDateKey[dateKey(for: date)] = metrics
    }

    // Temporary sample data so the summary UI has something to show.
    private func seedSampleData() {
        let today = Date()
        let monday = Self.mondayOfWeek(containing: today)

        // Monday..Friday
        let sample: [SavedSleepMetrics] = [
            .init(score: 72, timeAsleepSeconds: 6.2 * 3600, timeInBedSeconds: 7.8 * 3600),
            .init(score: 84, timeAsleepSeconds: 6.8 * 3600, timeInBedSeconds: 7.9 * 3600),
            .init(score: 91, timeAsleepSeconds: 7.1 * 3600, timeInBedSeconds: 7.7 * 3600),
            .init(score: 66, timeAsleepSeconds: 5.5 * 3600, timeInBedSeconds: 7.7 * 3600),
            .init(score: 78, timeAsleepSeconds: 6.4 * 3600, timeInBedSeconds: 8.0 * 3600)
        ]

        for offset in 0..<5 {
            let date = Calendar.current.date(byAdding: .day, value: offset, to: monday) ?? today
            save(metrics: sample[offset], for: date)
        }
    }

    private static func mondayOfWeek(containing date: Date) -> Date {
        // Swift Calendar weekday: Sunday=1, Monday=2, ...
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        let daysFromMonday = (weekday - 2 + 7) % 7
        return cal.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
    }
}

