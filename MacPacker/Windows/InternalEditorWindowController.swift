//
//  InternalEditorWindowController.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 22.11.23.
//

import Foundation
import AppKit
import SwiftUI

class TestEvObj: ObservableObject {
    @Published var text: String = ""
}

class InternalEditorWindowController: NSWindowController {
    static var shared = InternalEditorWindowController()
    private var internalEditorWindow: NSWindow? = nil
    private var evObj: TestEvObj = TestEvObj()
    
    private init() {
        // load the window
        internalEditorWindow = NSWindow()
        internalEditorWindow?.titlebarAppearsTransparent = true
        internalEditorWindow?.isMovableByWindowBackground = true
        internalEditorWindow?.showsToolbarButton = true
        internalEditorWindow?.styleMask = [.titled, .closable]
        internalEditorWindow?.setContentSize(NSSize(width: 480, height: 480))
        internalEditorWindow?.center()
        internalEditorWindow?.isReleasedWhenClosed = true
        
        var rootView = InternalEditorView()
            .environmentObject(evObj)
        let internalEditorHostingView = NSHostingView(rootView: rootView)
        internalEditorHostingView.autoresizingMask = [.width, .height]
        internalEditorWindow?.contentView = internalEditorHostingView
        
        super.init(window: internalEditorWindow)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(_ url: URL?) {
        if let url {
            let text = loadText(from: url)
            evObj.text = text
            print(text)
        }
        internalEditorWindow?.makeKeyAndOrderFront(self)
        self.showWindow(self)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    func loadText(from url: URL?) -> String {
        do {
            if let url {
                if let fileContents = try? String(contentsOf: url, encoding: .utf8) {
                    return fileContents
                }
                if let fileContents = try? String(contentsOf: url, encoding: .macOSRoman) {
                    return fileContents
                }
                return ""
            }
        }
        return ""
    }
    
    @objc func cancel(_ sender: Any?) {
        close()
    }
}
