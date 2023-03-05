//
//  BuWizzBridgeApp.swift
//  BuWizzBridge
//
//  Created by Javan Wood on 4/3/2023.
//

import SwiftUI
import Combine

@main
final class BuWizzBridgeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(logSet: logSet, status: status)
        }
    }
    
    let vehicleManager = VehicleManager()
    let logSet = LogSet()
    let status = Status()
    var bag = Set<AnyCancellable>()
    
    init() {
        vehicleManager.builder = SimpleVehicle.Builder()
        vehicleManager.logs.sink { [weak self] log in
            self?.logSet.logs.append(log)
        }.store(in: &bag)
        vehicleManager.events.sink { [weak self] event in
            print("trigger 1")
            guard let status = self?.status else { return }
            print("trigger 2")
            switch event {
            case .inputUpdate(timestamp: _, identifier: _, value: _): break
            case .signalStrength(timestamp: _, rssi: let rssi, latency: let latency):
                status.rssi = Double(rssi)
                status.latency = latency * 1000
            case .writeValue(timestamp: _, identifier: _, one: _, two: _, three: _, four: _, latency: _): break
            }
        }.store(in: &bag)
    }
}
