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
    public static let parent: FileItem = FileItem()
    let id = UUID()
    let path: URL?
    let fullPath: String
    let type: FileItemType
    @Published var name: String
    @Published var ext: String
    @Published var size: Int = -1
    
    //
    // Initializers
    //
    
    // Default constructor
    init(path: URL, type: FileItemType, size: Int? = nil, name: String? = nil) {
        self.path = path
        self.fullPath = path.absoluteString
        self.type = type
        self.name = name ?? path.lastPathComponent
        self.size = size ?? -1
        self.ext = ""
        
        if type != .directory {
            self.ext = getExtension(name: name ?? path.lastPathComponent)
        }
    }
    
    init(name: String, type: FileItemType, size: Int? = nil) {
        self.path = nil
        self.fullPath = ""
        self.name = name
        self.size = size ?? -1
        self.type = type
        self.ext = ""
        
        if type != .directory {
            self.ext = getExtension(name: name)
        }
    }
    
    private init() {
        self.path = nil
        self.fullPath = ""
        self.name = ".."
        self.size = 0
        self.type = .directory
        self.ext = ""
    }
    
    //
    // Functions
    //
    
    private func getExtension(name: String) -> String {
        guard let lastDotIndex = name.lastIndex(of: ".") else {
            return ""
        }
        
        if lastDotIndex == name.startIndex {
            return ""
        }
        
        let extensionStartIndex = name.index(after: lastDotIndex)
        return String(name[extensionStartIndex...])
    }
    
    // opens the item
    // - file > open using system functionality
    // - archive > open in macpacker
    // - directory > open in macpacker
    public func open(_ name: String) {
        
    }
    
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension FileItem: CustomStringConvertible {
    var description: String {
        return path == nil ? "" : path!.absoluteString
    }
}
