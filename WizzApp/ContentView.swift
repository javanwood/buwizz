//
//  ContentView.swift
//  WizzApp
//
//  Created by Javan Wood on 22/12/19.
//  Copyright © 2019 Javan Wood. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let vehicleManager: VehicleManager
    
    init(vehicleManager: VehicleManager) {
        self.vehicleManager = vehicleManager
        vehicleManager.targetVehicle = RalfBuilder()
    }
    
    var body: some View {
        Text("BuWizz").frame(width: 100, height: 100)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(vehicleManager: VehicleManager())
    }
}
