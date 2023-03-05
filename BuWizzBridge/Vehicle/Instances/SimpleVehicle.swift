//
//  SimpleVehicle.swift
//  BuWizzBridge
//
//  Created by Javan Wood on 5/3/2023.
//

import Foundation
import GameController
import Combine

class SimpleVehicle: Vehicle {
    
    class Builder : VehicleBuilder {
        private var buWizz: BuWizz? = nil
        private var controller: GCExtendedGamepad? = nil
        private let buWizzId = UUID(uuidString: "04456E17-65A1-5AB8-82E1-D1CB5E181778")!
        
        var buWizzTargets: [UUID] { return [buWizzId] }
        
        var vehicle: SimpleVehicle? {
            if let b = buWizz, let c = controller {
                return SimpleVehicle(buWizz: b, controller: c)
            }
            return nil
        }
        
        func addBuWizz(_ buWizz: BuWizz) {
            if buWizz.peripheral.identifier == buWizzId {
                self.buWizz = buWizz
            }
        }
        
        func addGamepad(_ gamepad: GCExtendedGamepad) {
            controller = gamepad
        }
    }
    
    let events: AnyPublisher<Event, Never>
    private let eventSource = PassthroughSubject<Event, Never>()
    
    let buWizz: BuWizz
    let controller: GCExtendedGamepad
    
    init(buWizz: BuWizz, controller: GCExtendedGamepad) {
        self.buWizz = buWizz
        self.controller = controller
        events = Publishers.Merge(eventSource, buWizz.events).eraseToAnyPublisher()
        
        controller.leftTrigger.valueChangedHandler = { _, _, _ in self.updateDriveInput() }
        controller.rightTrigger.valueChangedHandler = { _, _, _ in self.updateDriveInput() }
        controller.leftThumbstick.valueChangedHandler = { _, x, _ in
            self.buWizz.one = -Int8(x * 127)
        }
    }
    
    func updateDriveInput() {
        buWizz.two = Int8((controller.rightTrigger.value - controller.leftTrigger.value) * 127)
    }
}
