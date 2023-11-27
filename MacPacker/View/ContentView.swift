//
//  ContentView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 01.08.23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedFileItemID: Set<ArchiveItem.ID> = []
    @StateObject var breadcrumbs: Breadcrumbs = Breadcrumbs()
    @StateObject var store: Store = Store()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text(breadcrumbs.completePath ?? "")
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(8)
            ArchiveView()
        }
        .toolbar(id: "mainToolbar") {
            ToolbarView()
        }
        .environmentObject(breadcrumbs)
        .environmentObject(store)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
