//
//  ArchiveView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 31.08.23.
//

import Foundation
import SwiftUI

struct ArchiveView: View {
    @StateObject var container: FileContainer = FileContainer()
    @State private var isDraggingOver = false
    
    var body: some View {
        VStack {
            ArchiveTableView(
                data: $container.items,
                isReloadNeeded: $container.isReloadNeeded,
                container: container)
        }
        .border(isDraggingOver ? Color.blue : Color.clear, width: 2)
        .onDrop(of: ["public.file-url"], isTargeted: $isDraggingOver) { providers -> Bool in
            for provider in providers {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (data, error) in
                    if let data = data as? Data,
                        let fileURL = URL(dataRepresentation: data, relativeTo: nil) {
                        // Update the state variable with the accepted file URL
                        DispatchQueue.main.async {
                            self.drop(path: fileURL)
                        }
                    }
                }
            }
            return true
        }
    }
    
    //
    // functions
    //
    
    func drop(path: URL) {
        container.errorMessage = ""
        self.container.load(path)
    }
}
