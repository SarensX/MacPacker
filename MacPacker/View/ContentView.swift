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
        .toolbar(id: "mainToolbar") {
            ToolbarView()
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
}
