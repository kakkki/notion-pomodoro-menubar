//
//  ContentView.swift
//  notion-pomodoro
//
//  Created by Atsuki Kakehi on 2022/10/16.
//

import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    @Published var taskName: String = "None"
}

struct ContentView: View {

    let startTimerTrigger: PassthroughSubject<Void, Never>
    
    @ObservedObject var contentViewModel: ContentViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            Text(contentViewModel.taskName)
//            Text("メニューバーアプリができた")
            
            Button("Start Timer") {
                startTimerTrigger.send()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(startTimerTrigger: PassthroughSubject<Void, Never>(), contentViewModel: ContentViewModel())
    }
}
