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
    var hr:    Float = -1
    var spo2:  Float = -1
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    // MARK: - Published UI State
    @Published var isConnected = false
    @Published var statusText  = "Scanning..."
    @Published var sensorData  = SensorData()

    // MARK: - BLE internals
    private var centralManager: CBCentralManager!
    private var peripheral:     CBPeripheral?
    private var characteristic: CBCharacteristic?

    // MARK: - Sleep Analysis
    var sessionData: [SensorData] = []
    private let analyzer = SleepAnalyzer()

    // SwiftData context — injected from SwiftUI via ActiveView
    var modelContext: ModelContext?

    // MARK: - CSV Writing
    private var csvFileHandle:        FileHandle?
    private var csvFileURL:           URL?

    /// Timestamp of the very first sample — drives both the CSV name and
    /// the SwiftData record date so they always refer to the same night.
    var sessionFirstTimestamp: Date?  // internal: ActiveView sets this for testing

    private let rowFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return f
    }()

    private let fileFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // MARK: - Night date logic

    /// Before 1 PM → belongs to the previous calendar day's session.
    private func nightDate(for timestamp: Date) -> Date {
        let cal  = Calendar.current
        let hour = cal.component(.hour, from: timestamp)
        return hour < 13
            ? cal.date(byAdding: .day, value: -1, to: timestamp)!
            : timestamp
    }

    private func nightDateString(for timestamp: Date) -> String {
        fileFmt.string(from: nightDate(for: timestamp))
    }

    // MARK: - CSV helpers

    private func openCSVIfNeeded(firstTimestamp: Date) {
        guard csvFileHandle == nil else { return }

        let dateStr = nightDateString(for: firstTimestamp)
        let folder  = URL(fileURLWithPath: "/Users/rahimehta/sleepmetricanalysis")
        let url     = folder.appendingPathComponent("sleep_\(dateStr).csv")
        csvFileURL  = url

        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(
                atPath: url.path,
                contents: "time,x,y,z,hr,spo2\n".data(using: .utf8)
            )
            print("📄 New CSV → sleep_\(dateStr).csv")
        } else {
            print("📄 Resuming CSV → sleep_\(dateStr).csv")
        }

        csvFileHandle = try? FileHandle(forWritingTo: url)
        csvFileHandle?.seekToEndOfFile()
    }

    private func writeCSVRow(timestamp: Date, x: Float, y: Float, z: Float,
                              hr: Float, spo2: Float) {
        if sessionFirstTimestamp == nil {
            sessionFirstTimestamp = timestamp
            openCSVIfNeeded(firstTimestamp: timestamp)
        }
        let hrStr   = hr   < 0 ? "" : String(hr)
        let spo2Str = spo2 < 0 ? "" : String(spo2)
        let row = "\(rowFmt.string(from: timestamp)),\(x),\(y),\(z),\(hrStr),\(spo2Str)\n"
        csvFileHandle?.write(row.data(using: .utf8) ?? Data())
    }

    func closeCSV() {
        csvFileHandle?.closeFile()
        csvFileHandle = nil
        if let url = csvFileURL {
            print("📄 CSV closed → \(url.lastPathComponent)")
        }
        csvFileURL = nil
        // Keep sessionFirstTimestamp alive so runSleepAnalysis uses same night date
    }

    // MARK: - Init

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)
            statusText = "Scanning for NanoPPG..."
        } else {
            statusText = "Bluetooth unavailable"
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
        statusText = "Connecting..."
    }

    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        isConnected = true
        statusText  = "Connected to NanoPPG"
        sessionData.removeAll()
        peripheral.delegate = self
        peripheral.discoverServices([SERVICE_UUID])
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        isConnected = false
        statusText  = "Disconnected — analyzing..."
        closeCSV()
        runSleepAnalysis()
        sessionData.removeAll()
        sessionFirstTimestamp = nil   // reset for next session
        statusText = "Scanning..."
        centralManager.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)
    }

    // MARK: - CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([CHAR_UUID], for: service)
        }
    }

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

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard let data = characteristic.value, data.count == 20 else { return }

        let floats = data.withUnsafeBytes { ptr -> [Float] in
            Array(ptr.bindMemory(to: Float.self))
        }

        let now = Date()

        DispatchQueue.global(qos: .background).async {
            self.writeCSVRow(
                timestamp: now,
                x: floats[0], y: floats[1], z: floats[2],
                hr: floats[3], spo2: floats[4]
            )
        }

        DispatchQueue.main.async {
            self.sensorData = SensorData(
                accX: floats[0], accY: floats[1], accZ: floats[2],
                hr:   floats[3], spo2: floats[4]
            )
            self.sessionData.append(self.sensorData)
        }
    }

    // MARK: - Sleep Analysis

    func runSleepAnalysis() {
        guard let context = modelContext else {
            print("❌ modelContext not set")
            return
        }
        print("🧠 Running analysis on \(sessionData.count) samples")
        guard let result = analyzer.analyze(data: sessionData) else {
            print("❌ Not enough data to analyze")
            return
        }

        // Night date comes from the first timestamp — matches the CSV filename exactly
        let night = nightDate(for: sessionFirstTimestamp ?? Date())

        let entry = SleepResult(
            date:        night,
            durationMin: result.durationMin,
            sleepMin:    result.sleepMin,
            wakeMin:     result.wakeMin,
            efficiency:  result.efficiency,
            wakeBouts:   result.wakeBouts,
            avgHR:       result.avgHR,
            minHR:       result.minHR,
            maxHR:       result.maxHR,
            spo2Count:   result.spo2Drops,
            sleepScore:  result.sleepScore
        )
        context.insert(entry)
        print("💾 Saved → \(fileFmt.string(from: night))  score: \(result.sleepScore)")
    }
}
