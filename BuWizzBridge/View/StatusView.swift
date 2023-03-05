//
//  StatusView.swift
//  BuWizzBridge
//
//  Created by Javan Wood on 4/3/2023.
//

import SwiftUI

class Status: ObservableObject {
    @Published var rssi = 0.0
    @Published var latency = 0.0
    @Published var isConnected = false
    @Published var vehicleName = ""
}

struct StatusView: View {
    @ObservedObject var status: Status
    var body: some View {
        print("Update")
        return VStack {
            HStack {
                Text("\(status.vehicleName) (\(status.isConnected ? "Connected" : "Not Connected"))")
                        .foregroundColor(Colors.text)
                Spacer()
                Button("Switch Profile", action: {})
            }
            GeometryReader { metrics in
                HStack {
                    Text("RSSI: \(String(format: "%.2f", status.rssi)) dB")
                        .frame(width: metrics.size.width * 0.5, alignment: .leading)
                        .foregroundColor(Colors.text)
                    Text("Latency: \(String(format: "%.0f", status.latency)) ms")
                        .frame(width: metrics.size.width * 0.5, alignment: .leading)
                        .foregroundColor(Colors.text)
                }
            }
        }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        let status = Status()
        status.rssi = 24.5
        status.latency = 25
        status.vehicleName = "Ralf"
        return StatusView(status: status)
    }
}
