//
//  Archive.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 03.08.23.
//

import Foundation

enum FileItemType: Comparable {
    case file
    case directory
    case archive
}

class FileItem: ObservableObject, Identifiable, Hashable {
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id = UUID()
    let path: URL
    let type: FileItemType
    @Published var name: String
    @Published var size: Int64?
    
    //
    // Initializers
    //
    
    // Default constructor
    init(path: URL, type: FileItemType, size: Int64? = nil, name: String? = nil) {
        self.path = path
        self.type = type
        self.name = name ?? path.lastPathComponent
        self.size = size
    }
    
    //
    // Functions
    //
    
    // opens the item
    // - file > open using system functionality
    // - archive > open in macpacker
    // - directory > open in macpacker
    public func open(_ name: String) {
        
    }
}
