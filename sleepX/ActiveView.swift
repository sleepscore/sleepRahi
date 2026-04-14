import CoreBluetooth
import SwiftUI
import Combine
import SwiftData

final class ActiveViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
}

struct ActiveView: View {
    @StateObject private var viewModel = ActiveViewModel()
    @StateObject private var ble = BLEManager()

    @Environment(\.modelContext) private var context

    var body: some View {
        VStack(spacing: 16) {
            Button("🧪 Run Test Sleep") {
                runTestSleep()
            }
            .padding()

            Text("Active")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 24)

            VStack(spacing: 12) {
                Text("Status: \(ble.statusText)")
                Text("Heart Rate: \(Int(ble.sensorData.hr)) BPM")
                Text("SpO2: \(Int(ble.sensorData.spo2))%")
                Text("Acc X: \(ble.sensorData.accX, specifier: "%.2f")")
                Text("Acc Y: \(ble.sensorData.accY, specifier: "%.2f")")
                Text("Acc Z: \(ble.sensorData.accZ, specifier: "%.2f")")
            }

            Spacer()
        }
        .navigationTitle("Active View")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.bottom, 24)
        .onAppear {
            ble.modelContext = context
        }
    }

    func runTestSleep() {
        // Always set context right before running — don't rely on onAppear timing
        ble.modelContext = context

        let totalSamples = 8 * 60 * 60  // 8 hours at 1 Hz

        var fakeData: [SensorData] = []

        for i in 0..<totalSamples {
            let minute        = i / 60
            let cyclePosition = minute % 90

            var acc: Float = 0.05
            var hr:  Float = 60

            switch cyclePosition {
            case 0..<10:   acc = 0.15; hr = 70
            case 10..<40:  acc = 0.02; hr = 52
            case 40..<70:  acc = 0.06; hr = 60
            case 70..<85:  acc = 0.04; hr = Float.random(in: 62...75)
            default:       acc = 0.30; hr = 75
            }

            let noise = Float.random(in: -0.01...0.01)
            fakeData.append(SensorData(
                accX: acc + noise,
                accY: acc + noise,
                accZ: acc + noise,
                hr:   hr,
                spo2: 97
            ))
        }

        // Simulate a recording that started last night at 10:30 PM
        // so the night date = yesterday, matching a real overnight session
        let yesterday  = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let sleepStart = Calendar.current.date(
            bySettingHour: 22, minute: 30, second: 0, of: yesterday
        )!

        ble.sessionFirstTimestamp = sleepStart
        ble.sessionData           = fakeData

        print("🧪 Test sleep: \(fakeData.count) samples, night: \(sleepStart)")

        ble.runSleepAnalysis()
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .modelContainer(for: SleepResult.self, inMemory: true)
}
