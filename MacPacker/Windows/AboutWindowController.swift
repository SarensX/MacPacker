//
//  AboutWindowController.swift
//  FileFillet
//
//  Created by Arenswald, Stephan (059) on 21.05.23.
//

import Foundation
import AppKit
import SwiftUI

class AboutWindowController {
    static var shared = AboutWindowController()
    private var aboutWindow: NSWindow? = nil
    private var aboutWindowController: NSWindowController? = nil
    
    private init() {
        // load the window
        aboutWindow = NSWindow()
        aboutWindow?.titlebarAppearsTransparent = true
        aboutWindow?.isMovableByWindowBackground = true
        aboutWindow?.showsToolbarButton = true
        aboutWindow?.styleMask = [.titled, .closable]
        aboutWindow?.setContentSize(NSSize(width: 460, height: 420))
        aboutWindow?.center()
        
        let rootView = AboutView()
        let contentView = NSHostingView(rootView: rootView)
        contentView.autoresizingMask = [.width, .height]
        aboutWindow?.contentView = contentView
        
        aboutWindowController = NSWindowController(window: aboutWindow)
    }
    
    func show() {
        aboutWindow?.makeKeyAndOrderFront(self)
        aboutWindowController?.showWindow(self)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    func close() {
        aboutWindow?.close()
    }
}
