//
//  Archive2.swift
//  MacPacker
//
//  Created by Arenswald, Stephan on 24.09.23.
//

import Foundation

enum Archive2Type: String {
    case tar = "tar"
    case zip = "zip"
    case lz4 = "lz4"
}

/// Unused yet, but will be used in future to replace FileContainer
class Archive2 {
    @Published var path: URL?
    @Published var internalPath: String = "/"
    @Published var type: String
    @Published var stack: ArchiveItemStack = ArchiveItemStack()
    
    init(path: URL? = nil, internalPath: String, type: String) {
        self.path = path
        self.internalPath = internalPath
        self.type = type
    }
}
