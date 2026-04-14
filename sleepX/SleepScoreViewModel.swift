//
//  SleepScoreViewModel.swift
//  sleepX
//

import SwiftUI
import Combine

struct SleepScoreData {
    var score: Int
    var timeAsleepSeconds: TimeInterval
    var timeInBedSeconds: TimeInterval
    var avgHR: Double?
    var sleepEfficiencyPct: Double
    var spo2DropCount: Int
    var wakeBouts: Int
    var explanation0to60: String
    var explanation60to80: String
    var explanation80to90: String
    var explanation90to100: String
}

final class SleepScoreViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    @Published var data: SleepScoreData

    init(data: SleepScoreData) {
        self.data = data
    }

    init() {
        self.data = SleepScoreData(
            score: 82,
            timeAsleepSeconds: 6.5 * 3600,
            timeInBedSeconds:  8.0 * 3600,
            avgHR: 57,
            sleepEfficiencyPct: 86,
            spo2DropCount: 0,
            wakeBouts: 2,
            explanation0to60:   "Your sleep needs attention. Focus on consistent bedtimes and reducing wake interruptions.",
            explanation60to80:  "Decent sleep, but there's room to improve. Try limiting screen time before bed.",
            explanation80to90:  "Good sleep quality. Keep up your current routine and aim for more deep sleep.",
            explanation90to100: "Excellent sleep! You're recovering well and hitting all the key markers."
        )
    }

    var sleepEfficiency: Double {
        guard data.timeInBedSeconds > 0 else { return 0 }
        return max(0, min(1, data.timeAsleepSeconds / data.timeInBedSeconds))
    }

    func formatDuration(_ seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds / 60)
        let hours   = totalMinutes / 60
        let minutes = totalMinutes % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    func scoreColor() -> Color {
        switch data.score {
        case 90...100: return Color(red: 0.2,  green: 0.78, blue: 0.55)
        case 80..<90:  return Color(red: 0.36, green: 0.68, blue: 1.0)
        case 60..<80:  return Color(red: 1.0,  green: 0.72, blue: 0.3)
        default:       return Color(red: 1.0,  green: 0.38, blue: 0.38)
        }
    }

    func activeExplanationRangeTitle() -> String {
        switch data.score {
        case 90...100: return "90–100"
        case 80..<90:  return "80–90"
        case 60..<80:  return "60–80"
        default:       return "0–60"
        }
    }

    func activeExplanation() -> String {
        switch data.score {
        case 90...100: return data.explanation90to100
        case 80..<90:  return data.explanation80to90
        case 60..<80:  return data.explanation60to80
        default:       return data.explanation0to60
        }
    }
}
