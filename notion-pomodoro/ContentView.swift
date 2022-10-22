//
//  ContentView.swift
//  notion-pomodoro
//
//  Created by Atsuki Kakehi on 2022/10/16.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

class ContentViewModel: ObservableObject {
    @Published var taskName: String = "None"
}

struct ContentView: View {

    let startTimerTrigger: PassthroughSubject<Void, Never>
    let cancelTimerTrigger: PassthroughSubject<Void, Never>
    
    @ObservedObject var contentViewModel: ContentViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            Button(contentViewModel.taskName) {
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
                pasteboard.setString(contentViewModel.taskName, forType: NSPasteboard.PasteboardType.string)
            }
            
            Button("Start Timer") {
                startTimerTrigger.send()
            }
            
            Button("cancel Timer") {
                cancelTimerTrigger.send()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            startTimerTrigger: PassthroughSubject<Void, Never>(),
            cancelTimerTrigger: PassthroughSubject<Void, Never>(),
            contentViewModel: ContentViewModel()
        )
    }
}
