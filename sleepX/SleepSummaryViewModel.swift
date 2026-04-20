// Drives the summary calendar (week bounds, selected day, and mapping stored results to score view models)

import SwiftUI
import SwiftData
import Combine

final class SleepSummaryViewModel: ObservableObject {
    @Published var selectedDate:  Date
    @Published var weekStartDate: Date

    // Initial week and selected day
    init() {
        let monday       = Self.mondayOfWeek(containing: Date())
        self.weekStartDate = monday
        self.selectedDate  = monday
    }

    var weekEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 4, to: weekStartDate) ?? weekStartDate
    }

    // Calendar selection
    func selectDayFromCalendar(_ date: Date) {
        weekStartDate = Self.mondayOfWeek(containing: date)
        selectedDate  = date
    }

    // View model from a Stored night
    func scoreViewModel(from result: SleepResult) -> SleepScoreViewModel {
        let data = SleepScoreData(
            score:              result.sleepScore,
            timeAsleepSeconds:  result.sleepMin   * 60,
            timeInBedSeconds:   result.durationMin * 60,
            avgHR:              result.avgHR,
            sleepEfficiencyPct: result.efficiency,
            spo2DropCount:      result.spo2Count,
            wakeBouts:          result.wakeBouts,
            //explained sleep scores
            explanation0to60:   "Your sleep needs attention. Focus on consistent bedtimes and reducing wake interruptions.",
            explanation60to80:  "Decent sleep, but there's room to improve. Try limiting screen time before bed.",
            explanation80to90:  "Good sleep quality. Keep up your current routine and aim for more deep sleep.",
            explanation90to100: "Excellent sleep! You're recovering well and hitting all the key markers."
        )
        return SleepScoreViewModel(data: data)
    }

    // Same calendar day
    func isSameDay(_ a: Date, _ b: Date) -> Bool {
        Calendar.current.isDate(a, inSameDayAs: b)
    }

    // Monday of the week containing date
    private static func mondayOfWeek(containing date: Date) -> Date {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        let daysFromMonday = (weekday - 2 + 7) % 7
        return cal.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
    }
}
