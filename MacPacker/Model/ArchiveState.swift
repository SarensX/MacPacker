//
//  ArchiveState.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 04.05.25.
//

import Foundation
import SwiftUI

class ArchiveState: ObservableObject {
    @Published var archive: Archive2?
    @Published var archiveContainer: ArchiveContainer = ArchiveContainer()
    @Published var selectedItem: ArchiveItem? = nil
    @Published var openWithUrls: [URL] = []
    @Published var completePathArray: [String] = []
    @Published var completePath: String?
    
    init() {
        
    }
    
    init(completePath: String) {
        self.completePath = completePath
    }
}

extension ArchiveState {
    func loadUrl(_ url: URL) {
        createArchive(url: url)
    }
    
    func createArchive(url: URL) {
        do {
            let archive = try Archive2(
                url: url,
                breadcrumbsUpdated: breadcrumbsUpdated(breadcrumbs:))
            self.archive = archive
            self.archiveContainer.isReloadNeeded = true
        } catch {
            print(error)
        }
    }
    
    func breadcrumbsUpdated(breadcrumbs: [String]) {
        self.completePathArray = breadcrumbs
        self.completePath = breadcrumbs.joined(separator: "/")
    }
    
    /// Loads the given stack entry. Whenever something happens in MacPacker,
    /// a stack entry is created which in turn is then loaded. A stack entry basically
    /// defines at what folder/archive to look at.
    /// - Parameters:
    ///   - entry: stack entry
    ///   - clear: true to clear the full stack
    ///   - push: true to push the entry on that stack
    private func loadStackEntry(_ entry: ArchiveItemStackEntry, clear: Bool = false, push: Bool = true) {
        do {
            // stack item is directory that actually exists
            if entry.archivePath == nil {
                try loadDirectoryContent(url: entry.localPath)
                print("enable this")
            }
            
            // stack item is archive
            if let archivePath = entry.archivePath,
               let archiveType = entry.archiveType,
               let archive = self.archive {
                let archiveType = try ArchiveType.with(archiveType)
                
                if let content: [ArchiveItem] = try? archiveType.content(
                    path: entry.localPath,
                    archivePath: archivePath) {
                    
                    // sort the result
                    archive.items = content.sorted {
                        if $0.type == $1.type {
                            return $0.name < $1.name
                        }
                        
                        return $0.type > $1.type
                    }
                    if (archive.stack.count > 0 && push == true) || archive.stack.count > 1 {
                        archive.items.insert(ArchiveItem.parent, at: 0)
                    }
                }
            }
            
            // add the item to the stack and clear if requested
//            if clear { resetStack() }
            if push {
                if let archive = self.archive {
                    archive.stack.push(entry)
                }
            }
            
            if let archive = self.archive {
                // update the breadcrumb with the current path
                var names = archive.stack.names()
                if let last = archive.stack.last() {
                    names.insert(last.localPath.deletingLastPathComponent().path, at: 0)
                }
            }
            
            self.archive!.currentStackEntry = entry
        } catch {
            print(error)
        }
        
//        print(stack.description)
    }
    
    /// Checks if the given archive extension is supported to be loaded in MacPacker
    /// - Parameter ext: extension
    /// - Returns: true in case supported, false otherwise
    public func isSupportedArchive(ext: String) -> Bool {
        if let _ = Archive2Type(rawValue: ext) {
            return true
        }
        return false
    }
    
    /// Loads the content of the given directory. This is especially used
    /// when navigating outside of archives
    /// - Parameter url: url to load
    private func loadDirectoryContent(url: URL) throws {
        let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey])
        var resultDirectories: [ArchiveItem] = []
        var resultFiles: [ArchiveItem] = []
        
        // add the possibility to go up
        resultDirectories.append(ArchiveItem.parent)
        
        // now add all items in the dir
        for url in contents {
            var isDirectory = false
            var fileSize: Int = -1
            do {
                let resourceValue = try url.resourceValues(forKeys: [.isDirectoryKey, .totalFileSizeKey])
                isDirectory = resourceValue.isDirectory ?? false
                fileSize = resourceValue.totalFileSize ?? -1
            } catch {

            }
            
            var fileItemType: ArchiveItemType = isDirectory ? .directory : .file
            if fileItemType == .file && isSupportedArchive(ext: url.pathExtension) {
                fileItemType = .archive
            }
            let fileItem = ArchiveItem(path: url, type: fileItemType, size: fileSize)
            
            if fileItemType == .directory {
                resultDirectories.append(fileItem)
            } else {
                resultFiles.append(fileItem)
            }
        }
        if let archive = self.archive {
            archive.items = resultDirectories.sorted {
                return $0.name < $1.name
            }
            archive.items.append(contentsOf: resultFiles.sorted {
                return $0.name < $1.name
            })
            print("items loaded \(archive.items.count)")
        }
    }
}

