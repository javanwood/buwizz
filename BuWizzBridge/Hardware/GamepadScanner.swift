//
//  GamepadScanner.swift
//  WizzApp
//
//  Created by Javan Wood on 14/3/20.
//

import Foundation
import GameController

class ExtendedGamepadScanner {
    
    private var didDiscoverExtendedGamepad: ((GCExtendedGamepad) -> ())?
    
    private var timer: Timer?
    private var knownControllers = [GCController]()
    
    func startScan(didDiscoverExtendedGamepad: @escaping (GCExtendedGamepad) -> ()) {
        self.didDiscoverExtendedGamepad = didDiscoverExtendedGamepad
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            for c in GCController.controllers() {
                guard !self.knownControllers.contains(c) else { continue }
                self.knownControllers.append(c)
                if let ext = c.extendedGamepad {
                    self.didDiscoverExtendedGamepad?(ext)
                }
            }
        }
    }
    
    func stopScan() {
        timer?.invalidate()
        timer = nil
        didDiscoverExtendedGamepad = nil
    }
}
