//
//  ContentView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 01.08.23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            ArchiveBrowserView()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: "/Users/sarensw/Library/Containers/com.sarensx.MacPacker/Data/Library/Application Support/")
                } label: {
                    Image(systemName: "folder.badge.gearshape")
                }
                .help("Show application support folder")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
