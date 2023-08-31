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
//    @State private var selectedFileItem: FileItem.ID?
    @State private var sortOrder = [KeyPathComparator<FileItem>(\.name)]
    @Binding var selection: FileItem.ID?
    
    var body: some View {
        VStack(alignment: .leading) {
            Table(selection: $selection, sortOrder: $sortOrder) {
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
                }
                TableColumn("ext", value: \.ext) { item in
                    HStack {
                        Text(item.ext)
                        Spacer()
                    }
                }
                .width(ideal: 60, max: 80)
                TableColumn("size", value: \.size) { item in
                    HStack {
                        Spacer()
                        if item.size >= 0 {
                            Text(self.sizeAsHumanReadableString(item.size))
                        }
                    }
                }
                .width(ideal: 60, max: 120)
//                TableColumn("path", value: \.fullPath) { item in
//                    HStack {
//                        Text(item.fullPath)
//                        Spacer()
//                    }
//                    .contentShape(Rectangle())
//                    .gesture(TapGesture(count: 2).onEnded {
//                        print(item)
//                        doubleClick(on: item)
//                    }).simultaneousGesture(TapGesture().onEnded {
//                        self.selectedFileItem = item.id
//                    }
//                    .padding(.all, 0)
//                }
            } rows: {
                ForEach(container.items) { item in
                    TableRow(item)
//                        .itemProvider { item.itemProvider }
                        .itemProvider { NSItemProvider() }
                }
            }
            .tableStyle(.bordered(alternatesRowBackgrounds: true))
            .onDoubleClick {
                if let item = container.items.first(where: { $0.id == selection }) {
                    doubleClick(on: item)
                }
            }
            
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
    
    func sizeAsHumanReadableString(_ size: Int) -> String {
        if size < 0 {
            return ""
        }
        
        if size >= 1000000 {
            return String(size / 1000000) + " MB"
        }
        if size >= 1000 {
            return String(size / 1000) + " KB"
        }
        
        return ""
    }
    
    func drop(path: URL) {
        container.errorMessage = ""
        self.container.load(path)
    }
    
    func doubleClick(on item: FileItem) {
        print("double click triggered")
        container.errorMessage = ""
        do {
            try self.container.open(item)
        } catch {
            print(error)
        }
    }
}
