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
    
    /// ポモドーロが25分なので1タスク1500秒で設定
    static let pomodoroSeconds = 1500
    
    // TODO: メニューバータイトルの共通化
    /// iOS, NotionDev, Life Style, etc
    var taskName = "NP"
    var taskCategoryName = "NP[C]"
    
    var remainingTime = pomodoroSeconds
    
    let startTimerTrigger = PassthroughSubject<Void, Never>()
    var startTimerCancellable: AnyCancellable?
    
    var countDownCancellable: AnyCancellable?
    
    let cancelTimerTrigger = PassthroughSubject<Void, Never>()
    var cancelTimerCancellable: AnyCancellable?
    
    let contentViewModel = ContentViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("debug0000 applicationDidFinishLaunching notification : \(notification.description)")
        
        popover.behavior = .transient
        let contentView = ContentView(
            startTimerTrigger: startTimerTrigger,
            cancelTimerTrigger: cancelTimerTrigger,
            contentViewModel: contentViewModel
        )
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        guard let button = self.statusBarItem.button else { return }
        // アイコンの設定
//        button.image = NSImage(systemSymbolName: "camera.macro", accessibilityDescription: nil)
        /// テキストは設定できる
        /// テキストは長すぎると空白になってしまうみたい
        /// フォーカスしてるアプリケーションによっては、非表示になってしまう
        /// メニューバーを調整するか、メニューバーにはカウントダウンだけ表示するようにするか調整が必要
        button.title = "\(self.taskName) 25:00"
        
        // アクションの設定
        button.action = #selector(menuButtonAction(sender:))
        
        addObserver()
    }

    /// DeepLink経由での起動時のハンドリングを実行する
    ///  no-pomo:// を叩くと動く
    /// @see: https://qiita.com/minami1389227/items/e6b14a5979b35a2470d3
    func application(_ application: NSApplication, open urls: [URL]) {
        print("debug0000 application open : \(urls.description)")

        // メニューバーアプリが反応したのがわかりやすいようにメニューを開く
        menuButtonAction(sender: self)
        startTimerTrigger.send()
        
        guard
            let url = urls.first,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = urlComponents.queryItems,
            let queries = queryItems[0].value
        else { return }

        let queryWords = queries.split(separator: "_")
        print("debug0000 split : \(queryWords.description)")
        
        guard queryWords.count >= 2 else { return }
        let taskName = String(queryWords[0])
        let categoryName = String(queryWords[1])
        
        contentViewModel.taskName = taskName
        self.taskName = taskName
        self.taskCategoryName = categoryName
    }
    
    func addObserver() {
        startTimerCancellable = startTimerTrigger.sink { [weak self] _ in
            print("debug0000 start Timer")
            
            guard let button = self?.statusBarItem.button else { return }
            
            let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            
            self?.countDownCancellable = timer.sink { [weak self]_ in
                guard let self else { return }
                button.title = "\(self.taskName) \(self.convertSecondsToTime(timeInSeconds: self.remainingTime) ?? "")"
                guard self.remainingTime >= 0 else {                    
                    self.finishCountDown(menuBarButton: button)
                    return
                }
                self.remainingTime -= 1
            }
        }
//        .store(in: &cancellables)
        
        cancelTimerCancellable = cancelTimerTrigger.sink { [weak self] _ in
            guard let self else { return }
            guard let button = self.statusBarItem.button else { return }
            self.finishCountDown(menuBarButton: button)
        }
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
    
    func finishCountDown(menuBarButton: NSStatusBarButton) {
        countDownCancellable?.cancel()
        self.remainingTime = Self.pomodoroSeconds
        menuBarButton.title = "\(taskName) \(self.convertSecondsToTime(timeInSeconds: self.remainingTime) )"
    }
}
