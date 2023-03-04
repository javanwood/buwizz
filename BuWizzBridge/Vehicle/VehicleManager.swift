//
//  VehicleManager.swift
//  WizzApp
//
//  Created by Javan Wood on 14/3/20.
//

import Foundation

class VehicleManager {
    var builder: VehicleBuilder? {
        didSet {
            restartScan()
        }
    }
    
    private let buWizzConnectionManager = BuWizzConnectionManager()
    private var gamepadScanner = ExtendedGamepadScanner()
    private var vehicle: AnyObject? = nil
    
    init() {
        buWizzConnectionManager.didFinishSetup = { self.restartScan() }
    }
    
    func restartScan() {
        stopScan()
        guard let builder = self.builder else { return }
        buWizzConnectionManager.startScan(forBuWizzIds: builder.buWizzTargets) { buWizz in
            print("Found BuWizz: \(buWizz.peripheral.identifier)")
            self.builder?.addBuWizz(buWizz)
            self.tryBuild()
        }
        gamepadScanner.startScan { gamepad in
            print("Found Gamepad")
            self.builder?.addGamepad(gamepad)
            self.tryBuild()
        }
    }
    
    func tryBuild() {
        if let vehicle = builder?.vehicle {
            self.vehicle = vehicle
            stopScan()
        }
    }
    
    func stopScan() {
        gamepadScanner.stopScan()
        buWizzConnectionManager.stopScan()
    }
    
}
