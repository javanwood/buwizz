//
//  BuWizz.swift
//  WizzApp
//
//  Created by Javan Wood on 7/3/20.
//  Copyright © 2020 Javan Wood. All rights reserved.
//

import Foundation
import CoreBluetooth

//let infoCharacteristicUUID = CBUUID(string: "180A")
//let manufacturerNameUUID = CBUUID(string: "2A29")
//let modelNumberUUID = CBUUID(string: "2A24")
//let serialNumberStringUUID = CBUUID(string: "2A25")
//let firmwareRevisionStringUUID = CBUUID(string: "2A28")

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
    
    let peripheral: CBPeripheral
    
    fileprivate let motorControlService: CBService
    fileprivate let motorControlCharacteristic: CBCharacteristic
    
    fileprivate var state = State.ready
    fileprivate var writeBuffer = [Data]() {
        didSet { _step_send() }
    }
    
    fileprivate func _step_send() {
        guard let data = writeBuffer.first else {
            setMotorValues()
            return
        }
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
        super.init()
        peripheral.delegate = self
        setMotorValues()
        setPowerMode(.ludacris)
        _step_send()
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
        } else {
            state = .ready
            writeBuffer.remove(at: 0)
        }
    }
}
