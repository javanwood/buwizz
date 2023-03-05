//
//  Event.swift
//  BuWizzBridge
//
//  Created by Javan Wood on 4/3/2023.
//

import Foundation

enum Event: Hashable {
    case signalStrength(timestamp: Date, rssi: Int, latency: Double)
    case writeValue(timestamp: Date, identifier: String, one: Int8, two: Int8, three: Int8, four: Int8, latency: Double)
    case inputUpdate(timestamp: Date, identifier: String, value: Float)
}
