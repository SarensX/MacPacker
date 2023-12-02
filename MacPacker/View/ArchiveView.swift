//
//  ArchiveView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 31.08.23.
//

import Foundation
import SwiftUI

class ArchiveContainer: ObservableObject {
    @Published var isReloadNeeded: Bool = false
}

struct ArchiveView: View {
    @EnvironmentObject var store: Store
    @State private var isDraggingOver = false
    
    var body: some View {
        VStack {
            ArchiveTableView(
                isReloadNeeded: $store.archiveContainer.isReloadNeeded,
                archive: $store.archive) {
                    if let archive = store.archive {
                        return archive.currentStackEntry
                    }
                    return nil
                }
        }
        .border(isDraggingOver ? Color.blue : Color.clear, width: 2)
        .onDrop(of: ["public.file-url"], isTargeted: $isDraggingOver) { providers -> Bool in
            for provider in providers {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (data, error) in
                    if let data = data as? Data,
                        let fileURL = URL(dataRepresentation: data, relativeTo: nil) {
                        // Update the state variable with the accepted file URL
                        DispatchQueue.main.async {
                            self.drop(fileURL)
                        }
                    }
                }
            }
            return true
        }
        .onAppear {
            if store.openWithUrls.count > 0 {
                self.drop(store.openWithUrls[0])
            }
        }
    }
    
    //
    // functions
    //
    
    func drop(_ url: URL) {
        // we're loading a new archive here, so clean up the current stack first
        if let arc = store.archive {
            do {
                try arc.clean()
            } catch {
                print("clean during drop failed")
                print(error)
            }
        }
        
        store.createArchive(url: url)
    }
}
