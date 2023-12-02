//
//  ArchiveWindowController.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 01.12.23.
//

import Foundation
import AppKit
import SwiftUI

class ArchiveWindowController {
    static var shared = ArchiveWindowController()
    private var archiveWindowControllers: [NSWindowController] = []
    
    private init() {
    }
    
    func createAndShowWindow(urls: [URL]) {
        // load the window
        let archiveWindow = NSWindow()
        archiveWindow.titlebarAppearsTransparent = true
        archiveWindow.toolbarStyle = .unified
        archiveWindow.isMovableByWindowBackground = true
        archiveWindow.showsToolbarButton = true
        archiveWindow.styleMask = [.titled, .closable]
        archiveWindow.setContentSize(NSSize(width: 800, height: 400))
        
        let store = Store()
        store.openWithUrls = urls
        let rootView = ContentView()
            .environmentObject(store)
        let contentView = NSHostingView(rootView: rootView)
        contentView.autoresizingMask = [.width, .height]
        archiveWindow.contentView = contentView
        
        let archiveWindowController = NSWindowController(window: archiveWindow)
        archiveWindowControllers.append(archiveWindowController)
        
        archiveWindow.makeKeyAndOrderFront(self)
        archiveWindowController.showWindow(self)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}
