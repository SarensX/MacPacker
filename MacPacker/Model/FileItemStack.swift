//
//  FileItemStack.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 08.08.23.
//

import Foundation

import Foundation

enum FileItemStackType {
    case Directory
    case Archive
}

struct FileItemStackEntry {
    // type of item
    let type: FileItemStackType
    
    // path can be one of:
    // - path on local drive to file
    // - path on local drive to directory
    // - path in archive to file, not extracted
    // - path in archive to directory, not extracted
    // - path in archive to file, extracted archive
    // - path in archive to directory, extracted archive
//    private var path: String
    
    // This path contains the URL to the actual file
    // or directory on the local drive. In case we are
    // navigating in an archive right now, this url stays
    // the same
    let localPath: URL
    
    // path in the archive
    let archivePath: String?
    
    // id of the temporary extraction path
    let tempId: String?
    
    // type of the archive (to find the implementation quickly)
    let archiveType: String?
}

extension FileItemStackEntry: CustomStringConvertible {
    var description: String {
        var result = localPath.absoluteString + "\n"
        if let archivePath { result += "  " + archivePath + "\n" }
        if let tempId { result += "  " + tempId + "\n" }
        if let archiveType { result += "  " + archiveType + "\n" }
        
        return result
    }
}

struct FileItemStack {
    private var stack: [FileItemStackEntry] = []
    
    func peek() -> FileItemStackEntry? {
        guard let topElement = stack.first else { return nil }
        return topElement
    }
    
    @discardableResult
    mutating func pop() -> FileItemStackEntry? {
        if stack.count == 0 {
            return nil
        }
        return stack.removeFirst()
    }
  
    mutating func push(_ element: FileItemStackEntry) {
        stack.insert(element, at: 0)
    }
    
    mutating func clear() {
        stack = []
    }
}

extension FileItemStack: CustomStringConvertible {
    var description: String {
        let topDivider = "---FileItemStack---\n"
        let bottomDivider = "-----------\n"

        var stackElements: String = ""
        for item in stack {
            stackElements = stackElements + item.description + "\n"
        }

        return topDivider + stackElements + bottomDivider
    }
}
