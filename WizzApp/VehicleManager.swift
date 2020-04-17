//
//  VehicleManager.swift
//  WizzApp
//
//  Created by Javan Wood on 14/3/20.
//  Copyright © 2020 Javan Wood. All rights reserved.
//

import Foundation

class VehicleManager {
    var targetVehicle: VehicleBuilder? {
        didSet {
            // Start scans again
            restartScan()
        }
    }
    
    private let buWizzConnectionManager = BuWizzConnectionManager()
    private var gamepadScanner = ExtendedGamepadScanner()
    
    init() {
        buWizzConnectionManager.didFinishSetup = { self.restartScan() }
    }
    
    func restartScan() {
        self.gamepadScanner.stopScan()
        self.buWizzConnectionManager.stopScan()
        guard let tv = self.targetVehicle else {
            return
        }
        
        self.buWizzConnectionManager.startScan(forBuWizzIds: tv.buWizzTargets) { buWizz in
            tv.addBuWizz(buWizz)
            if tv.constructionComplete {
                self.buWizzConnectionManager.stopScan()
            }
        }
        gamepadScanner.startScan { gamepad in
            if let tv = self.targetVehicle {
                tv.addGamepad(gamepad)
                if tv.constructionComplete {
                    self.gamepadScanner.stopScan()
                }
            }
        }
    }
}
