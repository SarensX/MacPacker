//
//  ContentView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 01.08.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var archiveState: ArchiveState = ArchiveState()
    @EnvironmentObject var state: AppState
    @State private var selectedFileItemID: Set<ArchiveItem.ID> = []
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text(archiveState.completePath ?? "")
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(8)
            ArchiveView()
        }
        .toolbar {
//            ToolbarItemGroup {
                ToolbarItem(
                    id: "preview",
                    placement: .primaryAction,
                    showsByDefault: true
                ) {
                    Button {
                        if let archive = archiveState.archive,
                           let selectedItem = archiveState.selectedItem {
                            let url = archive.extractFileToTemp(selectedItem)
                            InternalEditorWindowController.shared.show(url)
                        }
                    } label: {
                        Image(systemName: "text.page.badge.magnifyingglass")
                    }
                }
            
                ToolbarItem(
                    id: "info",
                    placement: .primaryAction,
                    showsByDefault: true
                ) {
                    Button {
                        if let url = archiveState.archive?.url {
                            openGetInfoWnd(for: [url])
                        }
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
//            }
        }
        .onOpenURL { url in
            self.archiveState.loadUrl(url)
        }
        .environmentObject(archiveState)
        
    }
    
    private var selection: Binding<Set<ArchiveItem.ID>> {
        Binding(
            get: { selectedFileItemID },
            set: {
                selectedFileItemID = $0
                print("selection changed to \(String(describing: selectedFileItemID))")
            }
        )
    }
    
    func openGetInfoWnd(for urls: [URL]) {
        let pBoard = NSPasteboard(name: NSPasteboard.Name(rawValue: "pasteBoard_\(UUID().uuidString )") )
        
        pBoard.writeObjects(urls as [NSPasteboardWriting])
        
        NSPerformService("Finder/Show Info", pBoard)
    }
}
