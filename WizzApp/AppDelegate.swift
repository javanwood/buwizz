//
//  AppDelegate.swift
//  WizzApp
//
//  Created by Javan Wood on 22/12/19.
//  Copyright © 2019 Javan Wood. All rights reserved.
//

import Cocoa
import SwiftUI
import GameController

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var vehicleManager: VehicleManager!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        vehicleManager = VehicleManager()
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(vehicleManager: vehicleManager)

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
