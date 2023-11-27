//
//  Toolbar.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 22.08.23.
//

import Foundation
import SwiftUI

struct ToolbarView: CustomizableToolbarContent {
    @EnvironmentObject var store: Store
    private let applicationSupportDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first

    var body: some CustomizableToolbarContent {
        ToolbarItem(id: "view", placement: .cancellationAction) {
            Button(action: {
                if let archive = store.archive,
                   let selectedItem = store.selectedItem {
                    let url = archive.extractFileToTemp(selectedItem)
                    InternalEditorWindowController.shared.show(url)
                }
            }, label: {
                Label("View", systemImage: "eye")
            })
            .help("View in internal editor")
            .disabled(store.selectedItem == nil)
        }
        ToolbarItem(id: "settings", placement: .primaryAction) {
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
