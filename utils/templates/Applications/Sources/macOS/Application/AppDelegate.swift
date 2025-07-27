//
//  AppDelegate.swift
//  KN_TEMPLATE_MACOS_NAME
//
//  Created by Jonathan Lee on 6/16/25.
//

import Cocoa
import SwiftUI

@objc(AppDelegate)
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = .init(
            contentRect: .init(x: 0, y: 0, width: 480, height: 270),
            styleMask: [
                .miniaturizable,
                .closable,
                .resizable,
                .titled
            ],
            backing: .buffered,
            defer: false)
        window?.center()
        window?.title = "Hello, World!"
        window?.contentView = NSHostingView(rootView: MainView())
        window?.makeKeyAndOrderFront(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

