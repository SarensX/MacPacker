//
//  ArchiveView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 31.08.23.
//

import Foundation
import SwiftUI

class ArchiveContainer: ObservableObject {
    @Published var archive: Archive2?
    @Published var isReloadNeeded: Bool = false
}

struct ArchiveView: View {
//    @StateObject var container: FileContainer = FileContainer()
    @StateObject var archiveContainer: ArchiveContainer = ArchiveContainer()
    @State private var isDraggingOver = false
    
    var body: some View {
        VStack {
            ArchiveTableView(
//                data: $container.items,
                isReloadNeeded: $archiveContainer.isReloadNeeded,
//                container: container)
                archive: $archiveContainer.archive)
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
        .environmentObject(archiveContainer)
    }
    
    //
    // functions
    //
    
    func drop(_ url: URL) {
//        container.errorMessage = ""
//        self.container.load(path)
        
        do {
            let archive = try Archive2(url: url)
            archiveContainer.archive = archive
            
            archiveContainer.isReloadNeeded = true
        } catch {
            print(error)
        }
    }
}
