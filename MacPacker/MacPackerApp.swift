//
//  MacPackerApp.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 01.08.23.
//

import SwiftUI
import Sparkle

@main
struct MacPackerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate
    private let updaterController: SPUStandardUpdaterController
    
    init() {
        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
        // This is where you can also pass an updater delegate if you need one
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("MacPacker")
        }
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About MacPacker") {
                    AboutWindowController.shared.show()
                }
            }
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        print(">> \(urls)")
    }
}
