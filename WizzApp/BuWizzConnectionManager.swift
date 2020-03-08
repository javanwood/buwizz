//
//  BuWizzConnectionManager.swift
//  WizzApp
//
//  Created by Javan Wood on 8/3/20.
//  Copyright © 2020 Javan Wood. All rights reserved.
//

import Foundation
import CoreBluetooth

extension Array {
    mutating func removeFirst(where predicate: ((Element) -> Bool)) -> Bool {
        if let index = self.firstIndex(where: predicate) {
            self.remove(at: index)
            return true
        }
        return false
    }
}

fileprivate let motorControlServiceUUID = CBUUID(string: "4e050000-74fb-4481-88b3-9919b1676e93")
fileprivate let motorControlCharacteristicUUID = CBUUID(string: "92d1")

// Goal of this class is to prepare the peripheral for use as a BuWizz by loading services, characteristics.
fileprivate class InitialisingBuWizz: NSObject, CBPeripheralDelegate {
    let peripheral: CBPeripheral
    let finished: (BuWizz) -> ()
    
    var motorControlService: CBService? { didSet { validate() } }
    var motorControlCharacteristic: CBCharacteristic? { didSet { validate() } }
    
    init(peripheral: CBPeripheral, finished: @escaping (BuWizz) -> ()) {
        self.peripheral = peripheral
        self.finished = finished
        super.init()
        self.peripheral.delegate = self
        self.peripheral.discoverServices([motorControlServiceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let e = error {
            print("Did discover services error: \(e)")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            switch service.uuid {
            case motorControlServiceUUID:
                motorControlService = service
                self.peripheral.discoverCharacteristics([motorControlCharacteristicUUID], for: service)
            default: continue
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            switch characteristic.uuid {
            case motorControlCharacteristicUUID:
                motorControlCharacteristic = characteristic
            default: continue
            }
        }
    }
    
    func validate() {
        if
            let _motorControlService = motorControlService,
            let _motorControlCharacteristic = motorControlCharacteristic {
            finished(BuWizz(
                peripheral: self.peripheral,
                motorControlService: _motorControlService,
                motorControlCharacteristic: _motorControlCharacteristic
            ))
        }
    }
}

protocol BuWizzConnectionManagerDelegate: class {
    func didConnectBuWizz(buWizz: BuWizz)
}

class BuWizzConnectionManager: NSObject {
    fileprivate var centralManager: CBCentralManager!
    
    var connectedBuWizz: [BuWizz] = []
    fileprivate var initialisingBuWizz: [InitialisingBuWizz] = []
    fileprivate var peripheralsPendingConnection: [CBPeripheral] = []
    
    weak var delegate: BuWizzConnectionManagerDelegate?
    
    fileprivate var allPeripherals: Array<CBPeripheral> {
        return (connectedBuWizz.map { $0.peripheral }) + (initialisingBuWizz.map { $0.peripheral }) + peripheralsPendingConnection
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func cancelConnections(for buWizz: BuWizz) {
        _ = connectedBuWizz.removeFirst(where: { $0 == buWizz })
        centralManager.cancelPeripheralConnection(buWizz.peripheral)
    }
    
    func cancelAllConnections() {
        for peripheral in (connectedBuWizz.map { $0.peripheral }) + (initialisingBuWizz.map { $0.peripheral }) + peripheralsPendingConnection {
            centralManager.cancelPeripheralConnection(peripheral)
            
        }
    }
}

extension BuWizzConnectionManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn: central.scanForPeripherals(withServices: [motorControlServiceUUID], options: nil)
        case .poweredOff: print("Bluetooth is off")
        case .resetting: print("Bluetooth is resetting")
        case .unauthorized: print("Unauthorized")
        case .unknown: print("Unknown")
        case .unsupported: print("Unsupported")
        @unknown default:
            print("Unknown, unsupported case.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Make sure we don't already know about the peripheral
        if allPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            return
        }
        peripheralsPendingConnection.append(peripheral)
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheralsPendingConnection.removeFirst(where: { $0 == peripheral }) {
            let callback: (BuWizz) -> () = { [weak self] b in self?.finishedInitialising(buWizz: b) }
            self.initialisingBuWizz.append(InitialisingBuWizz(peripheral: peripheral, finished: callback))
        }
    }
    
    func finishedInitialising(buWizz: BuWizz) {
        if initialisingBuWizz.removeFirst(where: { $0.peripheral == buWizz.peripheral }) {
            connectedBuWizz.append(buWizz)
            delegate?.didConnectBuWizz(buWizz: buWizz)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        _ = peripheralsPendingConnection.removeFirst(where: { $0 == peripheral })
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let e = error else {
            return
        }
        if connectedBuWizz.removeFirst(where: { $0.peripheral == peripheral }) {
            print("BuWizz peripheral \(peripheral) disconnected because of error: \(e)")
        }
        if initialisingBuWizz.removeFirst(where: { $0.peripheral == peripheral }) {
            print("BuWizz peripheral in initialisation phase \(peripheral) disconnected because of error: \(e)")
        }
    }
}
