//
//  Thingo.swift
//  WizzApp
//
//  Created by Javan Wood on 9/3/20.
//  Copytop © 2020 Javan Wood. All tops reserved.
//

import Foundation
import GameController

class RalfVehicle {
    
    enum Gear {
        case high, low
    }
    
    let backBuWizz: BuWizz
    let topBuWizz: BuWizz
    let controller: GCExtendedGamepad
    
    fileprivate var gear: Gear
    func setGear(_ gear: Gear) {
        self.gear = gear
        switch gear {
        case .high: topBuWizz.one = -100
        case .low: topBuWizz.one = 100
        }
    }
    
    var gearUpPressed: Bool = false {
        didSet {
            if gearUpPressed && !oldValue {
                setGear(.high)
            }
        }
    }
    var gearDownPressed: Bool = false {
        didSet {
            if gearDownPressed && !oldValue {
                setGear(.low)
            }
        }
    }
    
    init(back: BuWizz, top: BuWizz, controller: GCExtendedGamepad) {
        backBuWizz = back
        topBuWizz = top
        self.controller = controller
        gear = .low
        setGear(.low)
        
        controller.leftTrigger.valueChangedHandler = { _, _, _ in self.updateDriveInput() }
        controller.rightTrigger.valueChangedHandler = { _, _, _ in self.updateDriveInput() }
        controller.leftThumbstick.valueChangedHandler = { _, x, _ in
            self.backBuWizz.one = -Int8(x * 127)
        }
        controller.buttonA.pressedChangedHandler = { _, _, pressed in self.gearDownPressed = pressed }
        controller.buttonX.pressedChangedHandler = { _, _, pressed in self.gearUpPressed = pressed }
    }
    
    func updateDriveInput() {
        let rawVal = Int8((controller.rightTrigger.value - controller.leftTrigger.value) * 127)
        let driveVal = max(rawVal, -100) // Break clipping
        backBuWizz.two = -driveVal
        topBuWizz.three = driveVal
    }
}

class RalfBuilder: VehicleBuilder {
    
    private let backBuWizzId = UUID(uuidString: "6DE747E6-6E95-43D8-A293-749C05B4415E")!
    private let topBuWizzId = UUID(uuidString: "221B8E84-49C0-4176-927D-69F7093EBF40")!
    let buWizzTargets: [UUID]
    
    private var back: BuWizz? = nil
    private var top: BuWizz? = nil
    private var controller: GCExtendedGamepad? = nil
    var vehicle: RalfVehicle?
    var constructionComplete: Bool { return vehicle != nil }
    
    init() {
        buWizzTargets = [backBuWizzId, topBuWizzId]
    }
    
    func useBuWizz(_ buWizz: BuWizz) {
        switch buWizz.peripheral.identifier {
        case backBuWizzId: back = buWizz
        case topBuWizzId: top = buWizz
        default: print("Found buwizz: \(buWizz.peripheral.identifier)")
        }
    }
    
    func useGamepad(_ gamepad: GCExtendedGamepad) {
        controller = gamepad
    }
    
    func tryBuild() {
        if let b = back, let t = top, let c = controller {
            print("buildSucceeded")
            vehicle = RalfVehicle(back: b, top: t, controller: c)
        }
    }
}
