//
//  BLEManager.swift
//  sleepX
//
//  Created by Ellen Baik on 4/7/26.
//

import Foundation
import CoreBluetooth
import Combine

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

    @Published var isConnected  = false
    @Published var statusText   = "Scanning..."
    @Published var sensorData   = SensorData()

    private var centralManager:  CBCentralManager!
    private var peripheral:      CBPeripheral?
    private var characteristic:  CBCharacteristic?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(
                withServices: [SERVICE_UUID],
                options: nil
            )
            statusText = "Scanning for NanoPPG..."
        } else {
            statusText = "Bluetooth unavailable"
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        // Found our Arduino — stop scanning and connect
        self.peripheral = peripheral
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
        statusText = "Connecting..."
    }

    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        isConnected = true
        statusText  = "Connected to NanoPPG"
        peripheral.delegate = self
        peripheral.discoverServices([SERVICE_UUID])
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        isConnected = false
        statusText  = "Disconnected — scanning..."
        // Auto-reconnect
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
                // Subscribe to notifications — this is how data streams to you
                peripheral.setNotifyValue(true, for: char)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard let data = characteristic.value, data.count == 32 else { return }

        // Unpack 8 × Float32 from the 32-byte packet
        let floats = data.withUnsafeBytes { ptr -> [Float] in
            Array(ptr.bindMemory(to: Float.self))
        }

        DispatchQueue.main.async {
            self.sensorData = SensorData(
                accX:  floats[0],
                accY:  floats[1],
                accZ:  floats[2],
                gyroX: floats[3],
                gyroY: floats[4],
                gyroZ: floats[5],
                hr:    floats[6],
                spo2:  floats[7]
            )
        }
    }
}
