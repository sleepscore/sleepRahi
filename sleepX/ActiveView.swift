//
//  ActiveView.swift
//  sleepX
//
//  Placeholder screen for active sleep tracking.
//
import CoreBluetooth
import SwiftUI
import Combine

final class ActiveViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    // Bluetooth/scoring state will be added here later.
}

struct ActiveView: View {
    @StateObject private var viewModel = ActiveViewModel()
    @StateObject private var ble = BLEManager()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Active")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 24)

            Text("Tracking is running. (Bluetooth + scoring coming next.)")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
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
    }
}

#Preview {
    NavigationStack {
        ActiveView()
    }
}

