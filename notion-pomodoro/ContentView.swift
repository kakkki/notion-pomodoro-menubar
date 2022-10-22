//
//  ContentView.swift
//  notion-pomodoro
//
//  Created by Atsuki Kakehi on 2022/10/16.
//

import SwiftUI
import Combine

struct ContentView: View {

    let startTimerTrigger: PassthroughSubject<Void, Never>

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
    
            Text("Hello, world!")
            
            Button("Start Timer") {
                startTimerTrigger.send()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(startTimerTrigger: PassthroughSubject<Void, Never>())
    }
}
