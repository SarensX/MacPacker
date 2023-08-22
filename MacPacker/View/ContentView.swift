//
//  ContentView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 01.08.23.
//

import SwiftUI

struct ContentView: View {
    let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first

    var body: some View {
        VStack {
            ArchiveBrowserView()
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Menu {
                    Button {
                        if let url = applicationSupportDirectory {
                            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
                        }
                    } label: {
                        Text("Open cache directory")
                    }
                    .help("Show application support folder")
                    .disabled(applicationSupportDirectory == nil)
                    Button {
                        clearCache()
                    } label: {
                        Text("Clear cache")
                    }
                    .help("Clears all content from the cache")
                    .disabled(applicationSupportDirectory == nil)
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
    }
    
    /// Clears the cache be deleting the ta directory in the applciation support directory
    func clearCache() {
        if let url = applicationSupportDirectory {
            do {
                try FileManager.default.removeItem(at: url.appendingPathComponent("ta", conformingTo: .directory))
            } catch {
                print("Could not clear cache because...")
                print(error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
