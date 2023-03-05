//
//  Log.swift
//  BuWizzBridge
//
//  Created by Javan Wood on 4/3/2023.
//

import SwiftUI
import Combine

class LogSet: ObservableObject {
    @Published var logs: [Log] = []
}

struct LogView: View {
    @ObservedObject var logSet: LogSet
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(logSet.logs, id: \.self) { log in
                    LogRow(log: log)
                }
            }
        }
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        let logSet = LogSet()
        logSet.logs = [
            Log(timestamp: Date.now, text: "Some other message"),
            Log(timestamp: Date.now, text: "Some mess message"),
            Log(timestamp: Date.now, text: "Some message"),
        ]
        return LogView(logSet: logSet).background(Colors.background).previewDevice("iPhone 14 Pro")
    }
}
