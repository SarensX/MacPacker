//
//  ContentView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 01.08.23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedFileItemID: Set<ArchiveItem.ID> = []
    
    var body: some View {
        VStack {
            ArchiveView()
        }
        .toolbar {
            Toolbar()
        }
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
