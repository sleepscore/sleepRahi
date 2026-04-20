// View model for the sleep score ring, metric text, colors, and score-band explanations.

import SwiftUI
import Combine

// Values shown on the screen
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

    // Asleep time divided by in-bed time
    var sleepEfficiency: Double {
        guard data.timeInBedSeconds > 0 else { return 0 }
        return max(0, min(1, data.timeAsleepSeconds / data.timeInBedSeconds))
    }

    // Human-readable duration formating
    func formatDuration(_ seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds / 60)
        let hours   = totalMinutes / 60
        let minutes = totalMinutes % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    // Ring color by score band
    func scoreColor() -> Color {
        switch data.score {
        case 90...100: return Color(red: 0.2,  green: 0.78, blue: 0.55)
        case 80..<90:  return Color(red: 0.36, green: 0.68, blue: 1.0)
        case 60..<80:  return Color(red: 1.0,  green: 0.72, blue: 0.3)
        default:       return Color(red: 1.0,  green: 0.38, blue: 0.38)
        }
    }

    // Explanation label for current score band
    func activeExplanationRangeTitle() -> String {
        switch data.score {
        case 90...100: return "90–100"
        case 80..<90:  return "80–90"
        case 60..<80:  return "60–80"
        default:       return "0–60"
        }
    }

    // Explanation copy for current score band
    func activeExplanation() -> String {
        switch data.score {
        case 90...100: return data.explanation90to100
        case 80..<90:  return data.explanation80to90
        case 60..<80:  return data.explanation60to80
        default:       return data.explanation0to60
        }
    }
}
