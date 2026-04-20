// Analyzes streamed sensor history to estimate sleep/wake and compute a composite sleep score.
import Foundation
import SwiftData

class SleepAnalyzer {

    let fs: Double = 1.0   // 1 sample per second

    struct Result {
        var durationMin: Double
        var sleepMin: Double
        var wakeMin: Double
        var efficiency: Double
        var wakeBouts: Int
        var avgHR: Double?
        var minHR: Double?
        var maxHR: Double?
        var rmssd: Double?
        var spo2Drops: Int
        var sleepScore: Int
    }

    func analyze(data: [SensorData]) -> Result? {
        guard data.count > 15 else { return nil }

        // Acceleration magnitude Calculation
        let accel = data.map {
            sqrt(Double($0.accX*$0.accX +
                        $0.accY*$0.accY +
                        $0.accZ*$0.accZ))
        }

        let ai = activityIndex(accel)
        let sleep = detectSleep(ai)

        return computeEndpoints(data: data, sleep: sleep)
    }

    // Activity index (rolling variance)
    func activityIndex(_ signal: [Double]) -> [Double] {
        let window = Int(fs * 60 * 20) // 20 min

        var result = Array(repeating: 0.0, count: signal.count)
        var sum = 0.0
        var sumSq = 0.0

        for i in 0..<signal.count {
            let x = signal[i]
            sum += x
            sumSq += x * x

            if i >= window {
                let old = signal[i - window]
                sum -= old
                sumSq -= old * old
            }

            let n = Double(min(i + 1, window))
            let mean = sum / n
            let variance = (sumSq / n) - (mean * mean)

            result[i] = variance
        }

        return result
    }

    // Sleep detection
    func detectSleep(_ ai: [Double]) -> [Int] {
        let threshold = percentile(ai, 75)

        let raw = ai.map { $0 < threshold ? 1 : 0 }

        let window = Int(fs * 60 * 15) // 15 min smoothing
        var smooth: [Double] = []

        for i in 0..<raw.count {
            let start = max(0, i - window)
            let slice = raw[start...i]
            let mean = Double(slice.reduce(0,+)) / Double(slice.count)
            smooth.append(mean)
        }

        return smooth.map { $0 > 0.5 ? 1 : 0 }
    }

    // Endpoints and derived metrics calculation
    func computeEndpoints(data: [SensorData], sleep: [Int]) -> Result? {

        let sleepIdx = sleep.enumerated().filter { $0.element == 1 }.map { $0.offset }
        if sleepIdx.isEmpty { return nil }

        let totalMinutes = Double(data.count) / 60.0
        let sleepMinutes = Double(sleepIdx.count) / 60.0
        let wakeMinutes = totalMinutes - sleepMinutes
        let efficiency = 100 * sleepMinutes / totalMinutes

        // Wake bouts (at least 90 seconds)
        let minWakeSamples = Int(90 * fs)

        var bouts = 0
        var currentWakeLength = 0
        var inWake = false

        for i in 0..<sleep.count {

            if sleep[i] == 0 {
                currentWakeLength += 1
                inWake = true
            } else {
                if inWake && currentWakeLength >= minWakeSamples {
                    bouts += 1
                }
                currentWakeLength = 0
                inWake = false
            }
        }

        if inWake && currentWakeLength >= minWakeSamples {
            bouts += 1
        }

        // Heart rate
        let hrValues = data.map { Double($0.hr) }.filter { $0 > 0 }

        let avgHR = hrValues.isEmpty ? nil : hrValues.reduce(0,+)/Double(hrValues.count)
        let minHR = hrValues.min()
        let maxHR = hrValues.max()

        let rmssd = computeRMSSD(hrValues: hrValues)

        // SpO2 drops
        let spo2Drops = data.filter { $0.spo2 > 0 && $0.spo2 < 90 }.count

        let score = computeSleepScore(
            sleepMin: sleepMinutes,
            efficiency: efficiency,
            wakeBouts: bouts,
            spo2Drops: spo2Drops,
            avgHR: avgHR,
            rmssd: rmssd
        )

        return Result(
            durationMin: totalMinutes,
            sleepMin: sleepMinutes,
            wakeMin: wakeMinutes,
            efficiency: efficiency,
            wakeBouts: bouts,
            avgHR: avgHR,
            minHR: minHR,
            maxHR: maxHR,
            rmssd: rmssd,
            spo2Drops: spo2Drops,
            sleepScore: score
        )
    }

    // HRV (RMSSD)
    func computeRMSSD(hrValues: [Double]) -> Double? {
        guard hrValues.count > 2 else { return nil }

        let rr = hrValues.map { 60.0 / $0 }

        var diffs: [Double] = []
        for i in 1..<rr.count {
            diffs.append(rr[i] - rr[i-1])
        }

        let meanSq = diffs.map { $0 * $0 }.reduce(0,+) / Double(diffs.count)
        return sqrt(meanSq)
    }

    // Composite sleep score
    func computeSleepScore(
        sleepMin: Double,
        efficiency: Double,
        wakeBouts: Int,
        spo2Drops: Int,
        avgHR: Double?,
        rmssd: Double?
    ) -> Int {

        // Duration (ideal ~8h)
        let durationScore = min(sleepMin / 480.0, 1.0) * 25

        // Efficiency
        let effScore = (efficiency / 100.0) * 20

        // Wake penalty
        let wakePenalty = min(Double(wakeBouts) / 25.0, 1.0)
        let wakeScore = (1 - wakePenalty) * 15

        // SpO2
        let spo2Penalty = min(Double(spo2Drops) / 5.0, 1.0)
        let spo2Score = (1 - spo2Penalty) * 15

        // HR
        let hrScore: Double
        if let avgHR = avgHR {
            hrScore = max(0, min((75 - avgHR)/25, 1)) * 10
        } else {
            hrScore = 5
        }

        // HRV
        let hrvScore: Double
        if let rmssd = rmssd {
            hrvScore = min(rmssd / 0.1, 1.0) * 15
        } else {
            hrvScore = 7
        }

        let total = durationScore + effScore + wakeScore + spo2Score + hrScore + hrvScore

        return max(1, min(100, Int(round(total))))
    }

    // Helpers
    func percentile(_ arr: [Double], _ p: Double) -> Double {
        let sorted = arr.sorted()
        let index = Int(Double(sorted.count) * p / 100.0)
        return sorted[min(index, sorted.count - 1)]
    }
}
