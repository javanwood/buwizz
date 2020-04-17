//
//  VehicleBuilder.swift
//  WizzApp
//
//  Created by Javan Wood on 14/3/20.
//  Copyright © 2020 Javan Wood. All rights reserved.
//

import Foundation
import GameController

protocol VehicleBuilder: class {
    func useBuWizz(_ buWizz: BuWizz)
    func useGamepad(_ gamepad: GCExtendedGamepad)
    var buWizzTargets: [UUID] { get }
    var constructionComplete: Bool { get }
    func tryBuild()
}

extension VehicleBuilder {
    func addBuWizz(_ buWizz: BuWizz) {
        useBuWizz(buWizz)
        tryBuild()
    }
    
    func addGamepad(_ gamepad: GCExtendedGamepad) {
        useGamepad(gamepad)
        tryBuild()
    }
}
