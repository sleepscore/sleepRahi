// SwiftData model: one stored night of sleep metrics and score after analysis.
import Foundation
import SwiftData

@Model
class SleepResult {
    var date: Date

    var durationMin: Double
    var sleepMin: Double
    var wakeMin: Double
    var efficiency: Double
    var wakeBouts: Int

    var avgHR: Double?
    var minHR: Double?
    var maxHR: Double?

    var spo2Count: Int
    var sleepScore: Int

    init(date: Date,
         durationMin: Double,
         sleepMin: Double,
         wakeMin: Double,
         efficiency: Double,
         wakeBouts: Int,
         avgHR: Double?,
         minHR: Double?,
         maxHR: Double?,
         spo2Count: Int,
         sleepScore: Int) {

        self.date = date
        self.durationMin = durationMin
        self.sleepMin = sleepMin
        self.wakeMin = wakeMin
        self.efficiency = efficiency
        self.wakeBouts = wakeBouts
        self.avgHR = avgHR
        self.minHR = minHR
        self.maxHR = maxHR
        self.spo2Count = spo2Count
        self.sleepScore = sleepScore
    }
}
