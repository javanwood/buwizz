//
//  ContentView.swift
//  WizzApp
//
//  Created by Javan Wood on 22/12/19.
//

import SwiftUI

struct ContentView: View {
    let logSet : LogSet
    let status : Status
    var body: some View {
        GeometryReader { metrics in
            ZStack {
                VStack(spacing: 0) {
                    StatusView(status: status)
                    LogView(logSet: logSet)
                }
            }.background(Colors.background).padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let logSet = LogSet()
        logSet.logs = [
            Log(timestamp: Date.now, text:"Hello")
        ]
        let status = Status()
        status.vehicleName = "Potato"
        status.rssi = 25
        status.latency = 10
        status.isConnected = true
        return ContentView(logSet: logSet, status: status)
            .previewDevice("iPhone 14 Pro")
    }
}
