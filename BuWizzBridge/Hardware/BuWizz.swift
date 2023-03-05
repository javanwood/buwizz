//
//  BuWizz.swift
//  WizzApp
//
//  Created by Javan Wood on 7/3/20.
//

import Foundation
import CoreBluetooth
import Combine

class BuWizz: NSObject {
    
    enum PowerMode: UInt8 {
        case slow = 01
        case normal = 02
        case fast = 03
        case ludacris = 04
    }
    
    fileprivate enum State {
        case ready, busy
    }
    
    var one: Int8 = 0
    var two: Int8 = 0
    var three: Int8 = 0
    var four: Int8 = 0
    
    fileprivate var timer: Timer? = nil
    
    fileprivate var writeTimestamp: Date? = nil
    fileprivate var rssiTimestamp: Date? = nil
    
    let events: AnyPublisher<Event, Never>
    private let eventsSource = PassthroughSubject<Event, Never>()
    
    let peripheral: CBPeripheral
    
    fileprivate let motorControlService: CBService
    fileprivate let motorControlCharacteristic: CBCharacteristic
    
    fileprivate var state = State.ready
    fileprivate var writeBuffer = [Data]() {
        didSet { _step_send() }
    }
    
    fileprivate func _step_send() {
        guard let data = writeBuffer.first else { return }
        switch state {
        case .ready:
            state = .busy
            peripheral.writeValue(data, for: motorControlCharacteristic, type: .withResponse)
        case .busy: return
        }
    }
    
    init(peripheral: CBPeripheral, motorControlService: CBService, motorControlCharacteristic: CBCharacteristic) {
        self.peripheral = peripheral
        self.motorControlService = motorControlService
        self.motorControlCharacteristic = motorControlCharacteristic
        events = eventsSource.eraseToAnyPublisher()
        super.init()
        peripheral.delegate = self
        setMotorValues()
        setPowerMode(.ludacris)
        _step_send()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.rssiTimestamp = Date.now
            self.peripheral.readRSSI()
        }
    }
    
    func setMotorValues() {
        let command: [UInt8] = [0x10, UInt8(bitPattern: one), UInt8(bitPattern: two), UInt8(bitPattern: three), UInt8(bitPattern: four), 0x00]
        writeBuffer.append(Data(command))
    }
    
    func setPowerMode(_ mode: PowerMode) {
        let command: [UInt8] = [0x11, mode.rawValue]
        writeBuffer.append(Data(command))
    }
}

extension BuWizz: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            print("Write failed with error \(e)")
            writeTimestamp = nil
        } else {
            state = .ready
            writeBuffer.remove(at: 0)
        }
    }
   
    // FYI this the way now for macOS too
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        let now = Date.now
        if let rssiStart = rssiTimestamp {
            eventsSource.send(Event.signalStrength(
                timestamp: now,
                rssi: RSSI.intValue,
                latency: now.timeIntervalSinceReferenceDate - rssiStart.timeIntervalSinceReferenceDate
            ))
            rssiTimestamp = nil
        }
    }
}
