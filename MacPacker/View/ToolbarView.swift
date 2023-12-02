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
    }
}
