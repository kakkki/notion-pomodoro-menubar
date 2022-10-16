//
//  notion_pomodoroApp.swift
//  notion-pomodoro
//
//  Created by Atsuki Kakehi on 2022/10/16.
//

import SwiftUI

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

    func applicationDidFinishLaunching(_ notification: Notification) {
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        guard let button = self.statusBarItem.button else { return }
        // アイコンの設定
        button.image = NSImage(systemSymbolName: "camera.macro", accessibilityDescription: nil)
        // アクションの設定
        button.action = #selector(menuButtonAction(sender:))
    }

    /// DeepLink経由での起動時のハンドリングを実行する
    ///  no-pomo:// を叩くと動く
    /// @see: https://qiita.com/minami1389227/items/e6b14a5979b35a2470d3
    func application(_ application: NSApplication, open urls: [URL]) {
        print("debug0000 application open : \(urls.description)")
        // メニューバーアプリが反応したのがわかりやすいようにメニューを開く
        menuButtonAction(sender: self)
        
//        print("url : \(url.absoluteString)")
//        print("scheme : \(url.scheme!)")
//        print("host : \(url.host!)")
//        print("port : \(url.port!)")
//        print("query : \(url.query!)")
    }
}

// MARK: Callback
private extension AppDelegate {
    @objc func menuButtonAction(sender: AnyObject) {
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
}
