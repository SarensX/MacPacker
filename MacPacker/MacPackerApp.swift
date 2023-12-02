//
//  MacPackerApp.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 01.08.23.
//

import SwiftUI
#if !STORE
import Sparkle
#endif

@main
struct MacPackerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate
    #if !STORE
    private let updaterController: SPUStandardUpdaterController
    #endif
    
    init() {
        #if !STORE
        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
        // This is where you can also pass an updater delegate if you need one
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        #endif
    }
    
    var body: some Scene {
        Settings {
            PreferencesView()
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About MacPacker") {
                    AboutWindowController.shared.show()
                }
            }
            #if !STORE
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
            #endif
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    @AppStorage("welcomeScreenShownInVersion") private var welcomeScreenShownInVersion = "0.0"
    private var openWithUrls: [URL] = []
    
    func application(_ application: NSApplication, open urls: [URL]) {
        print("User asked to open the following url with Open With... from the context menu")
        print(urls)
//        NotificationCenter.default.post(name: Notification.Name("file.load"), object: urls)
        ArchiveWindowController.shared.createAndShowWindow(urls: urls)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if Bundle.main.appVersionLong > welcomeScreenShownInVersion {
            WelcomeWindowController.shared.show()
            welcomeScreenShownInVersion = Bundle.main.appVersionLong
        }
        
        ArchiveWindowController.shared.createAndShowWindow(urls: openWithUrls)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        CacheCleaner.shared.clean()
    }
}
