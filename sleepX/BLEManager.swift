//
//  BLEManager.swift
//  sleepX
//
//  Created by Ellen Baik on 4/7/26.
//
 
import Foundation
import CoreBluetooth
import Combine
import SwiftData

// Must match your Arduino UUIDs exactly
let SERVICE_UUID = CBUUID(string: "12345678-1234-1234-1234-123456789abc")
let CHAR_UUID    = CBUUID(string: "12345678-1234-1234-1234-123456789def")
 
struct SensorData {
    var accX:  Float = 0
    var accY:  Float = 0
    var accZ:  Float = 0
    var gyroX: Float = 0
    var gyroY: Float = 0
    var gyroZ: Float = 0
    var hr:    Float = -1
    var spo2:  Float = -1
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    // MARK: - Published UI State
    @Published var isConnected  = false
    @Published var statusText   = "Scanning..."
    @Published var sensorData   = SensorData()

    // MARK: - BLE
    private var centralManager: CBCentralManager!
    private var peripheral:     CBPeripheral?
    private var characteristic: CBCharacteristic?

    // MARK: - Sleep Analysis
    var sessionData: [SensorData] = []
    private let analyzer = SleepAnalyzer()

    // 🔥 IMPORTANT: Must be injected from SwiftUI
    var modelContext: ModelContext?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Bluetooth State

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(
                withServices: [SERVICE_UUID],
                options: nil
            )
            statusText = "Scanning for device..."
        } else {
            statusText = "Bluetooth unavailable"
        }
    }

    // MARK: - Discovery

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {

        self.peripheral = peripheral
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)

        statusText = "Connecting..."
    }

    // MARK: - Connected

    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {

        isConnected = true
        statusText  = "Connected"

        sessionData.removeAll() // start fresh session

        peripheral.delegate = self
        peripheral.discoverServices([SERVICE_UUID])
    }

    // MARK: - Disconnected → RUN ANALYSIS

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {

        isConnected = false
        statusText  = "Disconnected — analyzing..."

        runSleepAnalysis()

        sessionData.removeAll()

        statusText = "Scanning..."
        centralManager.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)
    }

    // MARK: - Services

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {

        guard let services = peripheral.services else { return }

        for service in services {
            peripheral.discoverCharacteristics([CHAR_UUID], for: service)
        }
    }

    // MARK: - Characteristics

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {

        guard let chars = service.characteristics else { return }

        for char in chars {
            if char.uuid == CHAR_UUID {
                characteristic = char
                peripheral.setNotifyValue(true, for: char)
            }
        }
    }

    // MARK: - Data Streaming

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {

        guard let data = characteristic.value, data.count == 32 else { return }

        let floats = data.withUnsafeBytes { ptr -> [Float] in
            Array(ptr.bindMemory(to: Float.self))
        }

        let newData = SensorData(
            accX:  floats[0],
            accY:  floats[1],
            accZ:  floats[2],
            gyroX: floats[3],
            gyroY: floats[4],
            gyroZ: floats[5],
            hr:    floats[6],
            spo2:  floats[7]
        )

        DispatchQueue.main.async {
            self.sensorData = newData
        }

        // ✅ Store for analysis
        sessionData.append(newData)
    }

    // MARK: - Sleep Analysis

    func runSleepAnalysis() {
        guard let context = modelContext else {
            print("❌ modelContext not set")
            return
        }

        print("🧠 Running sleep analysis on \(sessionData.count) samples")

        guard let result = analyzer.analyze(data: sessionData) else {
            print("❌ Analysis failed")
            return
        }

        let entry = SleepResult(
            date: Date(),
            durationMin: result.durationMin,
            sleepMin: result.sleepMin,
            wakeMin: result.wakeMin,
            efficiency: result.efficiency,
            wakeBouts: result.wakeBouts,
            avgHR: result.avgHR,
            minHR: result.minHR,
            maxHR: result.maxHR,
            spo2Count: result.spo2Drops,
            sleepScore: result.sleepScore
        )

        context.insert(entry)

        print("💾 Sleep saved → Score: \(result.sleepScore)")
    }
}
