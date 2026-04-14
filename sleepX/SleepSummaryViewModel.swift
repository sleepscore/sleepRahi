//
//  SleepSummaryViewModel.swift
//  sleepX
//

import SwiftUI
import SwiftData
import Combine

final class SleepSummaryViewModel: ObservableObject {
    @Published var selectedDate:  Date
    @Published var weekStartDate: Date

    init() {
        let monday       = Self.mondayOfWeek(containing: Date())
        self.weekStartDate = monday
        self.selectedDate  = monday
    }

    var weekEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 4, to: weekStartDate) ?? weekStartDate
    }

    func selectDayFromCalendar(_ date: Date) {
        weekStartDate = Self.mondayOfWeek(containing: date)
        selectedDate  = date
    }

    /// Build a SleepScoreViewModel from a SwiftData SleepResult.
    func scoreViewModel(from result: SleepResult) -> SleepScoreViewModel {
        let data = SleepScoreData(
            score:              result.sleepScore,
            timeAsleepSeconds:  result.sleepMin   * 60,
            timeInBedSeconds:   result.durationMin * 60,
            avgHR:              result.avgHR,
            sleepEfficiencyPct: result.efficiency,
            spo2DropCount:      result.spo2Count,
            wakeBouts:          result.wakeBouts,
            explanation0to60:   "Your sleep needs attention. Focus on consistent bedtimes and reducing wake interruptions.",
            explanation60to80:  "Decent sleep, but there's room to improve. Try limiting screen time before bed.",
            explanation80to90:  "Good sleep quality. Keep up your current routine and aim for more deep sleep.",
            explanation90to100: "Excellent sleep! You're recovering well and hitting all the key markers."
        )
        return SleepScoreViewModel(data: data)
    }

    func isSameDay(_ a: Date, _ b: Date) -> Bool {
        Calendar.current.isDate(a, inSameDayAs: b)
    }

    private static func mondayOfWeek(containing date: Date) -> Date {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        let daysFromMonday = (weekday - 2 + 7) % 7
        return cal.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
    }
}
