//
//  VehicleManager.swift
//  WizzApp
//
//  Created by Javan Wood on 14/3/20.
//

import Foundation
import Combine

class VehicleManager {
    var builder: (any VehicleBuilder)? {
        didSet {
            restartScan()
        }
    }
    
    private let buWizzConnectionManager = BuWizzConnectionManager()
    private var gamepadScanner = ExtendedGamepadScanner()
    private var vehicle: (any Vehicle)? = nil
    
    private let logsSubject = PassthroughSubject<Log, Never>()
    private let eventsSourceSubject = PassthroughSubject<AnyPublisher<Event, Never>, Never>()
    let logs: AnyPublisher<Log, Never>
    let events: AnyPublisher<Event, Never>
    
    init() {
        logs = logsSubject.eraseToAnyPublisher()
        // https://www.vadimbulavin.com/map-flatmap-switchtolatest-in-combine-framework/
        events = eventsSourceSubject.switchToLatest().eraseToAnyPublisher()
        
        buWizzConnectionManager.didFinishSetup = { self.restartScan() }
    }
    
    func restartScan() {
        stopScan()
        guard let builder = self.builder else { return }
        buWizzConnectionManager.startScan(forBuWizzIds: builder.buWizzTargets) { buWizz in
            self.logsSubject.send(Log(timestamp: Date.now, text: "Found BuWizz \(buWizz.peripheral.identifier)"))
            self.builder?.addBuWizz(buWizz)
            self.tryBuild()
        }
        gamepadScanner.startScan { gamepad in
            self.logsSubject.send(Log(timestamp: Date.now, text: "Found Gamepad"))
            self.builder?.addGamepad(gamepad)
            self.tryBuild()
        }
    }
    
    func tryBuild() {
        if let vehicle = builder?.vehicle {
            self.vehicle = vehicle
            eventsSourceSubject.send(vehicle.events.eraseToAnyPublisher())
            self.logsSubject.send(Log(timestamp: Date.now, text: "Vehicle ready to go"))
            stopScan()
        }
    }
    
    func stopScan() {
        gamepadScanner.stopScan()
        buWizzConnectionManager.stopScan()
    }
    
}
