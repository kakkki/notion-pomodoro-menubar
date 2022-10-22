//
//  notion_pomodoroApp.swift
//  notion-pomodoro
//
//  Created by Atsuki Kakehi on 2022/10/16.
//

import SwiftUI
import Combine

/// 【Swift】SwiftUIでメニューバーアプリの作り方
/// @see: https://qiita.com/SNQ-2001/items/7e8ac52e9e8726228806

// MARK: Main
@main
struct SwiftUI_MenuBar_DemoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        Settings { }
    }
}

// MARK: NSApplicationDelegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var popover = NSPopover()
    
//    private var cancellables: Set<AnyCancellable> = []
    
    let startTimerTrigger = PassthroughSubject<Void, Never>()
    var startTimerCancellable: AnyCancellable?
    var timerCancellable: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("debug0000 applicationDidFinishLaunching notification : \(notification.description)")
        
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView(startTimerTrigger: startTimerTrigger))
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        guard let button = self.statusBarItem.button else { return }
        // アイコンの設定
//        button.image = NSImage(systemSymbolName: "camera.macro", accessibilityDescription: nil)
        /// テキストは設定できる
        /// テキストは長すぎると空白になってしまうみたい
        /// フォーカスしてるアプリケーションによっては、非表示になってしまう
        /// メニューバーを調整するか、メニューバーにはカウントダウンだけ表示するようにするか調整が必要
        button.title = "NP 25:00"
        // アクションの設定
        button.action = #selector(menuButtonAction(sender:))
        
        addObserver()
    }

    /// DeepLink経由での起動時のハンドリングを実行する
    ///  no-pomo:// を叩くと動く
    /// @see: https://qiita.com/minami1389227/items/e6b14a5979b35a2470d3
    func application(_ application: NSApplication, open urls: [URL]) {
        print("debug0000 application open")
        print("debug0000 application open : \(urls.description)")
        // メニューバーアプリが反応したのがわかりやすいようにメニューを開く
        menuButtonAction(sender: self)
        
//        print("url : \(url.absoluteString)")
//        print("scheme : \(url.scheme!)")
//        print("host : \(url.host!)")
//        print("port : \(url.port!)")
//        print("query : \(url.query!)")
    }
    
    func addObserver() {
        print("debug0000 addObserver 15:34")
        startTimerCancellable = startTimerTrigger.sink { [weak self] _ in
            print("debug0000 start Timer")
            
            guard let button = self?.statusBarItem.button else { return }
            
            var remainingTime = 3
            
            let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            
            self?.timerCancellable = timer.sink { _ in
                button.title = "NP \(self?.convertSecondsToTime(timeInSeconds: remainingTime) ?? "")"
                guard remainingTime >= 0 else {
                    print("debug0000 canceled")
                    
                    self?.timerCancellable?.cancel()
                    
                    // 25:00 に戻す
                    button.title = "NP \(self?.convertSecondsToTime(timeInSeconds: 1500) ?? "")"
                    return
                }
                remainingTime -= 1
            }
        }
//        .store(in: &cancellables)
    }
    
}

// MARK: Callback
private extension AppDelegate {
    @objc func menuButtonAction(sender: AnyObject) {
        print("debug0000 menuButtonAction")
        guard let button = self.statusBarItem.button else { return }
        if self.popover.isShown {
            self.popover.performClose(sender)
        } else {
            // ポップアップを表示
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            // 他の位置をタップすると消える
            self.popover.contentViewController?.view.window?.makeKey()
        }
    }
    
    /// @see https://www.youtube.com/watch?v=_WJzpPgHkhg
    /// ここでの Combineを使用したカウントダウン処理を参考にした
    func convertSecondsToTime(timeInSeconds: Int) -> String {
        let minutes = timeInSeconds / 60
        let seconds = timeInSeconds % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    /// 現状使ってない
    func cancel() {
        startTimerCancellable?.cancel()
//        cancellables.forEach { $0.cancel() }
    }
}
