import CoreBluetooth
import SwiftUI
import Combine
import SwiftData   // ✅ ADD THIS

final class ActiveViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
}

struct ActiveView: View {
    @StateObject private var viewModel = ActiveViewModel()
    @StateObject private var ble = BLEManager()

    @Environment(\.modelContext) private var context   // ✅ ADD THIS

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
                Text("Gyro X: \(ble.sensorData.gyroX, specifier: "%.2f")")
                Text("Gyro Y: \(ble.sensorData.gyroY, specifier: "%.2f")")
                Text("Gyro Z: \(ble.sensorData.gyroZ, specifier: "%.2f")")
            }

            Spacer()
        }
        .navigationTitle("Active View")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.bottom, 24)

        // 🔥 THIS IS THE CRITICAL LINE
        .onAppear {
            ble.modelContext = context
            
        }
    }
    func runTestSleep() {
        let fs = 1
        let totalMinutes = 8 * 60   // 8 hours
        let totalSamples = totalMinutes * 60   // 1 Hz

        var fakeData: [SensorData] = []

        for i in 0..<totalSamples {

            let minute = i / 60
            let cyclePosition = minute % 90

            var acc: Float = 0.05
            var hr: Float = 60

            switch cyclePosition {

            case 0..<10:
                acc = 0.15
                hr = 70

            case 10..<40:
                acc = 0.02
                hr = 52

            case 40..<70:
                acc = 0.06
                hr = 60

            case 70..<85:
                acc = 0.04
                hr = Float.random(in: 62...75)

            default:
                acc = 0.3
                hr = 75
            }

            let noise = Float.random(in: -0.01...0.01)

            let data = SensorData(
                accX: acc + noise,
                accY: acc + noise,
                accZ: acc + noise,
                gyroX: 0,
                gyroY: 0,
                gyroZ: 0,
                hr: hr,
                spo2: 97
            )

            fakeData.append(data)
        }

        ble.sessionData = fakeData

        print("🧪 Realistic sleep sim (1Hz): \(fakeData.count) samples")
        
        ble.runSleepAnalysis()
    }
}


#Preview {
    NavigationStack {
        ActiveView()
    }
}

