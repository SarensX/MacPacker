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

    var body: some View {
        VStack {
            ArchiveTableView(data: $container.items, isReloadNeeded: $container.isReloadNeeded)
        }
        .onDrop(of: ["public.file-url"], isTargeted: nil) { providers -> Bool in
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
