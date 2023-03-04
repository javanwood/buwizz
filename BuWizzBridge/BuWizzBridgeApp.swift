//
//  BuWizzBridgeApp.swift
//  BuWizzBridge
//
//  Created by Javan Wood on 4/3/2023.
//

import SwiftUI

@main
struct BuWizzBridgeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    let vehicleManager = VehicleManager()
    
    init() {
        vehicleManager.builder = RalfVehicle.Builder()
    }
}
