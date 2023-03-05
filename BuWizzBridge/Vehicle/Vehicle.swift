//
//  Vehicle.swift
//  BuWizzBridge
//
//  Created by Javan Wood on 5/3/2023.
//

import Foundation
import Combine

protocol Vehicle {
    var events: AnyPublisher<Event, Never> { get }
}
