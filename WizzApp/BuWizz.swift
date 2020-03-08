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
    fileprivate enum State {
        case ready, busy
    }
    
    let peripheral: CBPeripheral
    
    fileprivate let motorControlService: CBService
    fileprivate let motorControlCharacteristic: CBCharacteristic
    
    fileprivate var writeBuffer = [Data]()
    fileprivate var state = State.ready
    
    init(peripheral: CBPeripheral, motorControlService: CBService, motorControlCharacteristic: CBCharacteristic) {
        self.peripheral = peripheral
        self.motorControlService = motorControlService
        self.motorControlCharacteristic = motorControlCharacteristic
        super.init()
        peripheral.delegate = self
    }
    
    func write(_ bytes: [UInt8]) {
        let data = Data(bytes)
        writeBuffer.append(data)
        send()
    }
    
    fileprivate func send() {
        guard let data = writeBuffer.first else {
            return
        }
        switch state {
        case .ready:
            peripheral.writeValue(data, for: motorControlCharacteristic, type: .withResponse)
            state = .busy
        case .busy: return
        }
    }
}

extension BuWizz: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            print("Write failed with error \(e)")
        } else {
            writeBuffer.remove(at: 0)
            state = .ready
            send()
        }
    }
}
