//
//  LogRow.swift
//  BuWizzBridge
//
//  Created by Javan Wood on 4/3/2023.
//

import SwiftUI

struct LogRow: View {
    let log: Log
    let dateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .medium
        return df
    }()
    var body: some View {
        HStack(alignment:.top) {
            Text(dateFormatter.string(from: log.timestamp))
                .foregroundColor(Colors.text)
                .textSelection(.enabled)
            Text(log.text)
                .foregroundColor(Colors.text)
                .textSelection(.enabled)
        }.padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
    }
}

struct LogRow_Previews: PreviewProvider {
    static var previews: some View {
        LogRow(log: Log(timestamp: Date.now, text: "Some message really long message asl;kefjalskejf alskefj alskejf alskefj "))
            .background(Colors.background).previewDevice("iPhone 14 Pro")
    }
}
