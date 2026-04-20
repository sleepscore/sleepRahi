// Live tracking screen: shows BLE status and real-time sensor readings; ends the session when the user goes back.

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
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text("Active")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 24)
            
            // Real-time metrics
            VStack(spacing: 12) {
                Text("Status: \(ble.statusText)")
                Text("Heart Rate: \(Int(ble.sensorData.hr)) BPM")
                Text("SpO2: \(Int(ble.sensorData.spo2))%")
                Text("Acc X: \(ble.sensorData.accX, specifier: "%.2f")")
                Text("Acc Y: \(ble.sensorData.accY, specifier: "%.2f")")
                Text("Acc Z: \(ble.sensorData.accZ, specifier: "%.2f")")
            }

            // Spacer to keep content near the top
            Spacer()
        }
        // Navigation bar setup
        .navigationTitle("Active View")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        
        // Custom back button that ends the active session
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    ble.endActiveSession {
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
        // Layout and context injection
        .padding(.bottom, 24)
        .onAppear {
            ble.modelContext = context
        }
    }
}

#Preview {
    NavigationStack {
        ActiveView()
    }
    .modelContainer(for: SleepResult.self, inMemory: true)
}
