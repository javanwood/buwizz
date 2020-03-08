//
//  AppDelegate.swift
//  WizzApp
//
//  Created by Javan Wood on 22/12/19.
//  Copyright © 2019 Javan Wood. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var connectionManager: BuWizzConnectionManager!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        connectionManager = BuWizzConnectionManager()
        connectionManager.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate: BuWizzConnectionManagerDelegate {
    func didConnectBuWizz(buWizz: BuWizz) {
        print("Connected BuWizz: \(buWizz)")
        buWizz.write([0x10, 0x00, 0x00, 0x00, 0x00, 0x00])
        buWizz.write([0x11, 0x02])
        buWizz.write([0x10, 0x00, 0x00, 0x0e, 0x00, 0x00])
        buWizz.write([0x10, 0x00, 0x00, 0x34, 0x00, 0x00])
        buWizz.write([0x10, 0x00, 0x00, 0x4f, 0x00, 0x00])
        buWizz.write([0x10, 0x00, 0x00, 0x5e, 0x00, 0x00])
    }
}

