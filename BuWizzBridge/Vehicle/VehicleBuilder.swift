//
//  VehicleBuilder.swift
//  WizzApp
//
//  Created by Javan Wood on 14/3/20.
//

import Foundation
import GameController

protocol VehicleBuilder: AnyObject {
    func addBuWizz(_ buWizz: BuWizz)
    func addGamepad(_ gamepad: GCExtendedGamepad)
    var buWizzTargets: [UUID] { get }
    var vehicle: AnyObject? { get }
}
