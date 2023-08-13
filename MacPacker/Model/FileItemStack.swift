//
//  FileItemStack.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 08.08.23.
//

import Foundation

import Foundation

struct FileItemStack {
    private var items: [FileItem] = []
    
    func peek() -> FileItem? {
        guard let topElement = items.first else { return nil }
        return topElement
    }
    
    @discardableResult
    mutating func pop() -> FileItem? {
        if items.count == 0 {
            return nil
        }
        return items.removeFirst()
    }
  
    mutating func push(_ element: FileItem) {
        items.insert(element, at: 0)
    }
    
    mutating func clear() {
        items = []
    }
}

extension FileItemStack: CustomStringConvertible {
    var description: String {
        let topDivider = "---FileItemStack---\n"
        let bottomDivider = "-----------\n"

        var stackElements: String = ""
        for item in items {
            stackElements = stackElements + item.description + "\n"
        }

        return topDivider + stackElements + bottomDivider
    }
}
