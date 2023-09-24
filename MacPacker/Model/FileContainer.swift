//
//  FileContainer.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 04.08.23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum SupportedArchiveTypes: String, CaseIterable {
    case lz4 = "lz4"
    case tar = "tar"
    case zip = "zip"
}

class FileContainer: ObservableObject {
    @Published var items: [FileItem] = []
    @Published var errorMessage: String?
    @Published var stack: FileItemStack = FileItemStack()
    @Published var tempArchives: [IArchive] = []
    @Published var isReloadNeeded: Bool = false
    public static var currentStackEntry: FileItemStackEntry? = nil
    
    //
    // Initializers
    //
    
    // Default constructor
    init() {
    }
    
    //
    // Functions
    //
    
    private func loadStackEntry(_ entry: FileItemStackEntry, clear: Bool = false, push: Bool = true) {
        do {
            // stack item is directory that actually exists
            if entry.archivePath == nil {
                try loadDirectoryContent(path: entry.localPath)
            }
            
            // stack item is archive
            if let archivePath = entry.archivePath,
               let archiveType = entry.archiveType {
                let archive = try Archive.with(archiveType)
                
                if let content: [FileItem] = try? archive.content(
                    path: entry.localPath,
                    archivePath: archivePath) {
                    
                    // sort the result
                    items = content.sorted {
                        if $0.type == $1.type {
                            return $0.name < $1.name
                        }
                        
                        return $0.type > $1.type
                    }
                }
            }
            
            // add the item to the stack and clear if requested
            if clear { resetStack() }
            if push { stack.push(entry) }
            FileContainer.currentStackEntry = entry
            
            isReloadNeeded = true
        } catch {
            print(error)
        }
        
        print(stack.description)
    }
    
    /// Loads the directory/archive/file from the given path. This is done when you drag/drop an
    /// item to the window or when you open an item using the open dialog
    /// - Parameter path: path to load
    public func load(_ path: URL) {
        
        // load the content depending of the type
        do {
            // Check if this is a dir first. This will throw in case
            // the path does not exist
            let isDirectory = try isDirectory(path: path)
            
            if isDirectory {
                // directory
                let stackEntry = FileItemStackEntry(
                    type: .Directory,
                    localPath: path,
                    archivePath: nil,
                    tempId: nil,
                    archiveType: nil)
                loadStackEntry(stackEntry, clear: true)
            } else {
                if isSupportedArchive(path: path) {
                    // archive
                    let stackEntry = FileItemStackEntry(
                        type: .Archive,
                        localPath: path,
                        archivePath: "",
                        tempId: nil,
                        archiveType: path.pathExtension)
                    loadStackEntry(stackEntry, clear: true)
                }
            }
            
            print(stack.description)
            
        } catch let error as CocoaError {
            switch error.code {
            case .fileReadNoPermission, .fileReadUnknown:
                print("no access")
                errorMessage = "MacPacker does not have access to the parent directory."
            case .fileNoSuchFile:
                print("file not found")
                errorMessage = "The given file does not seem to exist"
            default:
                print("unknown CocoaError")
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    /// Opens the given item. This can be one of the following cases:
    /// - File in directory > open the file with system default action
    /// - Directory > show the content of the directory
    /// - Archive > show the content of the archive depending on the archive type
    /// - File in archive > extract just this file if possible, then open it with system default
    /// - Directory in archive > go one level down in archive if this is supported, otherwise, extract and then go to directory
    /// - Parameter item: The item to open
    public func open(_ item: FileItem) throws {
        // if the selected item is the parent item (the one with ..),
        // then just go back in the stack
        if item == FileItem.parent {
            if stack.count > 1 { stack.pop() }
            if let parent = stack.peek() {
                loadStackEntry(parent, push: false)
            }
            return
        }
        
        // The item selected is not the parent. So check if this is a file,
        // and if yes, whether it is a supported archive.
        if item.type == .file {
            if isSupportedArchive(ext: item.ext) {
                // file, and supported archive, open as a new stack entry
                
                // two possibilities
                // 1. the archive selected is extracted already > just open it,
                //    but set tempId, not archive path
                // 2. it is not extracted, so it was shown in the file list based
                //    on the virtual archive contetn > extract first, then create
                //    stackentry
                if let currentStackEntry = stack.peek() {
                    if currentStackEntry.type == .Archive && currentStackEntry.archivePath == nil {
                        // the previous stack entry is an archive, and the archive path is nil which
                        // means that it physically exists on the local drive
                        
                        // distinguish between a real local drive vs a temp drive
                        if currentStackEntry.tempId == nil {
                            print("Error: this should not happen")
                        } else {
                            if let path = item.path {
                                let stackEntry = FileItemStackEntry(
                                    type: .Archive,
                                    localPath: path,
                                    archivePath: "",
                                    tempId: nil,
                                    archiveType: item.ext)
                                loadStackEntry(stackEntry)
                            }
                        }
                    } else if currentStackEntry.type == .Archive && currentStackEntry.archivePath != nil {
                        // the previous stack entry is an archive, but there is no
                        // temp id, so it was not extracted yet
                        // > extract first
                        if let archiveType = currentStackEntry.archiveType,
                           let tempDir = try? Archive
                            .with(archiveType)
                            .extractFileToTemp(
                                path: currentStackEntry.localPath,
                                item: item) {
                            
                            // now, create the new stack entry
                            let stackEntry = FileItemStackEntry(
                                type: .Archive,
                                localPath: tempDir,
                                archivePath: "",
                                tempId: nil,
                                archiveType: item.ext)
                            loadStackEntry(stackEntry)
                        }
                    } else if currentStackEntry.type == .Directory {
                        // just open the file in this case using the system methods
                    }
                }
            } else {
                // TODO file, but not an archive, so extract and open using sytem
            }
        } else if item.type == .directory {
            if let currentStackEntry = stack.peek(),
               let archivePath = currentStackEntry.archivePath {
                let stackEntry = FileItemStackEntry(
                    type: .Archive,
                    localPath: currentStackEntry.localPath,
                    archivePath: archivePath == "" ? item.name : archivePath + "/" + item.name,
                    tempId: currentStackEntry.tempId,
                    archiveType: currentStackEntry.archiveType)
                loadStackEntry(stackEntry)
            }
        }
    }
    
    
    /// Checks if the given archive extension is supported to be loaded in MacPacker
    /// - Parameter ext: extension
    /// - Returns: true in case supported, false otherwise
    public func isSupportedArchive(ext: String) -> Bool {
        if let _ = SupportedArchiveTypes(rawValue: ext) {
            return true
        }
        return false
    }
    
    /// Checks if the given archive extension is supported to be loaded in MacPacker
    /// - Parameter ext: extension
    /// - Returns: true in case supported, false otherwise
    public func isSupportedArchive(path: URL) -> Bool {
        let name = path.lastPathComponent
        
        if let ext = name.components(separatedBy: ".").last,
           let _ = SupportedArchiveTypes(rawValue: ext) {
            return true
        }
        return false
    }
    
    /// Checks if the given file exists
    /// - Parameter path: URL to check for existance
    /// - Returns: true in case the file/dir on that path exists, false otherwise
    public func isExists(path: URL) -> Bool {
//        if #available(macOS 13.0, *) {
//            if FileManager.default.fileExists(atPath: path.path()) {
//                return true
//            }
//        } else {
        if FileManager.default.fileExists(atPath: path.path) {
            return true
        }
//        }
        return false
    }
    
    /// Checks if the given path is a directory
    /// - Parameter path: path to the potential directory
    /// - Returns: true in case the path is a dir, false otherwise
    public func isDirectory(path: URL) throws -> Bool {
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: path.path, isDirectory: &isDirectory) {
            items = []
            throw CocoaError(.fileNoSuchFile)
        }
        
        return isDirectory.boolValue
    }
    
    // Loads the contents of the directory/archive
    private func loadDirectoryContent(path: URL) throws {
//        let contents = try FileManager.default.contentsOfDirectory(atPath: path.path)
        let contents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: [.isDirectoryKey])
        var resultDirectories: [FileItem] = []
        var resultFiles: [FileItem] = []
        
        // add the possibility to go up
        resultDirectories.append(FileItem(path: path.deletingLastPathComponent(), type: .directory, name: ".."))
        
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
//            var isDir: ObjCBool = false
//            FileManager.default.fileExists(atPath: u, isDirectory: &isDir)
//            let isDirectory = isDir.boolValue
//
//            let url = URL(fileURLWithPath: u)
//            let fileSize = 0
            
            var fileItemType: FileItemType = isDirectory ? .directory : .file
            if fileItemType == .file && isSupportedArchive(ext: url.pathExtension) {
                fileItemType = .archive
            }
            let fileItem = FileItem(path: url, type: fileItemType, size: fileSize)
            
            if fileItemType == .directory {
                resultDirectories.append(fileItem)
            } else {
                resultFiles.append(fileItem)
            }
        }
        items = resultDirectories.sorted {
            return $0.name < $1.name
        }
        items.append(contentsOf: resultFiles.sorted {
            return $0.name < $1.name
        })
        print("items loaded \(items.count)")
    }
    
    /// Loads the given archive by extracting it and loading its content
    /// - Parameter item: the archive as FileItem
    private func loadArchiveContent(_ item: FileItem) throws {
//        var archive: IArchive? = nil
//        if item.ext == SupportedArchiveTypes.lz4.rawValue {
//            archive = ArchiveLz4(item)
//        } else if item.ext == SupportedArchiveTypes.tar.rawValue {
//            archive = ArchiveTar(item)
//        }
//
//        if let archive {
//            items = try archive.content().sorted {
//                if $0.type == $1.type {
//                    return $0.name < $1.name
//                }
//
//                return $0.type > $1.type
//            }
//            tempArchives.append(archive)
//        }
    }
    
    private func resetStack() {
        self.stack.clear()
    }
}
