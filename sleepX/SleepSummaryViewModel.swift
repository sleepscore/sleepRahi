//
//  SleepSummaryViewModel.swift
//  sleepX
//
//  Week/day picker for displaying previously-saved sleep results.
//

import SwiftUI
import Combine

final class SleepSummaryViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    @Published var weekStartDate: Date // Monday of selected week
    @Published var selectedDate: Date // chosen day within that week

    private let store: SleepResultsStore

    init(store: SleepResultsStore = .shared, initialWeekStartDate: Date = Date()) {
        self.store = store
        let monday = Self.mondayOfWeek(containing: initialWeekStartDate)
        self.weekStartDate = monday
        self.selectedDate = monday
    }

    var weekEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 4, to: weekStartDate) ?? weekStartDate
    }

    var weekDatesMondayToFriday: [Date] {
        (0..<5).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: weekStartDate) }
    }

    func metrics(for date: Date) -> SavedSleepMetrics? {
        store.metrics(for: date)
    }

    func sleepScoreViewModel(for date: Date) -> SleepScoreViewModel? {
        guard let metrics = metrics(for: date) else { return nil }
        let data = SleepScoreData.makeWithSavedMetrics(
            score: metrics.score,
            timeAsleepSeconds: metrics.timeAsleepSeconds,
            timeInBedSeconds: metrics.timeInBedSeconds
        )
        return SleepScoreViewModel(data: data)
    }

    func setWeekStartDate(_ newDate: Date) {
        let monday = Self.mondayOfWeek(containing: newDate)
        weekStartDate = monday
        selectedDate = monday
    }

    private static func mondayOfWeek(containing date: Date) -> Date {
        // Swift Calendar weekday: Sunday=1, Monday=2, ...
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        let daysFromMonday = (weekday - 2 + 7) % 7
        return cal.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
    }
}

