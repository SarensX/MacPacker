//
//  Toolbar.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 22.08.23.
//

import Foundation
import SwiftUI

struct Toolbar: ToolbarContent {
    private let applicationSupportDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first

    var body: some ToolbarContent {
        ToolbarItemGroup {
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
    
    /// Clears the cache be deleting the ta directory in the applciation support directory
    func clearCache() {
        CacheCleaner.shared.clean()
    }
}
