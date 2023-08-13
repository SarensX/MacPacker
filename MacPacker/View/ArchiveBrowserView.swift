//
//  ArchiveBrowserView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 03.08.23.
//

import Foundation
import SwiftUI

struct ArchiveBrowserView: View {
    @StateObject var container: FileContainer = FileContainer()
    @State private var selectedFileItem: FileItem.ID?
    @State private var sortOrder = [KeyPathComparator<FileItem>(\.name)]
    
    var body: some View {
        VStack(alignment: .leading) {
            Table(of: FileItem.self, selection: $selectedFileItem, sortOrder: $sortOrder) {
                TableColumn("name", value: \.name) { item in
                    HStack {
                        if item.type == .directory {
                            Image(systemName: "folder")
                                .frame(width: 14)
                        } else {
                            Text("")
                                .frame(width: 14)
                        }
                        Text(item.name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .gesture(TapGesture(count: 2).onEnded {
                        print(item)
                        doubleClick(on: item)
                    }).simultaneousGesture(TapGesture().onEnded {
                        self.selectedFileItem = item.id
                    })
//                    .background(.red)
                    .padding(.all, 0)
                }
                TableColumn("path", value: \.fullPath) { item in
                    HStack {
                        Text(item.fullPath)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .gesture(TapGesture(count: 2).onEnded {
                        print(item)
                        doubleClick(on: item)
                    }).simultaneousGesture(TapGesture().onEnded {
                        self.selectedFileItem = item.id
                    })
//                    .background(.green)
                    .padding(.all, 0)
                }
            } rows: {
                ForEach(container.items) {
                    TableRow($0)
                }
            }
            .tableStyle(.bordered(alternatesRowBackgrounds: true))
            
            if let errorMessage = container.errorMessage {
                Text(errorMessage)
                    .padding(.bottom, 2)
                    .frame(alignment: .topLeading)
            }
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
    
    func doubleClick(on item: FileItem) {
        container.errorMessage = ""
        self.container.open(item)
    }
}
