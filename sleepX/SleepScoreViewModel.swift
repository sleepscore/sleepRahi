//
//  SleepScoreViewModel.swift
//  sleepX
//
//  View model for the Sleep Score Index screen.
//

import SwiftUI
import Combine

struct SleepScoreData {
    var score: Int // 0...100
    var timeAsleepSeconds: TimeInterval
    var timeInBedSeconds: TimeInterval
    var explanation0to60: String
    var explanation60to80: String
    var explanation80to90: String
    var explanation90to100: String

    // For screens that only have previously-saved metrics.
    static func makeWithSavedMetrics(
        score: Int,
        timeAsleepSeconds: TimeInterval,
        timeInBedSeconds: TimeInterval
    ) -> SleepScoreData {
        SleepScoreData(
            score: score,
            timeAsleepSeconds: timeAsleepSeconds,
            timeInBedSeconds: timeInBedSeconds,
            explanation0to60: "Example explanation for a score in the 0–60 range.",
            explanation60to80: "Example explanation for a score in the 60–80 range.",
            explanation80to90: "Example explanation for a score in the 80–90 range.",
            explanation90to100: "Example explanation for a score in the 90–100 range."
        )
    }
}

final class SleepScoreViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    // In a real app, these would be updated by Bluetooth readings + your scoring logic.
    @Published var data: SleepScoreData

    init(data: SleepScoreData) {
        self.data = data
    }

    init() {
        self.data = SleepScoreData(
            score: 82,
            timeAsleepSeconds: 6.5 * 3600,
            timeInBedSeconds: 8.0 * 3600,
            explanation0to60: "Example explanation for a score in the 0–60 range.",
            explanation60to80: "Example explanation for a score in the 60–80 range.",
            explanation80to90: "Example explanation for a score in the 80–90 range.",
            explanation90to100: "Example explanation for a score in the 90–100 range."
        )
    }

    var sleepEfficiency: Double {
        guard data.timeInBedSeconds > 0 else { return 0 }
        return max(0, min(1, data.timeAsleepSeconds / data.timeInBedSeconds))
    }

    func formatDuration(_ seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    func scoreColor() -> Color {
        switch data.score {
        case 90...100: return .green
        case 80..<90: return .yellow
        case 60..<80: return .orange
        default: return .red
        }
    }

    func activeExplanationRangeTitle() -> String {
        switch data.score {
        case 90...100: return "90–100"
        case 80..<90: return "80–90"
        case 60..<80: return "60–80"
        default: return "0–60"
        }
    }

    func activeExplanation() -> String {
        switch data.score {
        case 90...100: return data.explanation90to100
        case 80..<90: return data.explanation80to90
        case 60..<80: return data.explanation60to80
        default: return data.explanation0to60
        }
    }

    // Editable explanation bindings (reassign to ensure SwiftUI sees the change).
    func setExplanation0to60(_ value: String) {
        var updated = data
        updated.explanation0to60 = value
        data = updated
    }
    func setExplanation60to80(_ value: String) {
        var updated = data
        updated.explanation60to80 = value
        data = updated
    }
    func setExplanation80to90(_ value: String) {
        var updated = data
        updated.explanation80to90 = value
        data = updated
    }
    func setExplanation90to100(_ value: String) {
        var updated = data
        updated.explanation90to100 = value
        data = updated
    }
}

