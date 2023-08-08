//
//  FileContainer.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 04.08.23.
//

import Foundation

enum ContainerType {
    case directory
    case archive
    case none
}

enum SupportedArchiveTypes: String, CaseIterable {
    case lz4 = "lz4"
    case tar = "tar"
}

class FileContainer: ObservableObject {
    @Published var type: ContainerType = .none
    @Published var items: [FileItem] = []
    @Published var errorMessage: String?
    @Published var stack: FileItemStack = FileItemStack()
    
    //
    // Initializers
    //
    
    // Default constructor
    init() {
    }
    
    //
    // Functions
    //
    
    /// Loads the directory/archive/file from the tiven path
    /// - Parameter path: path to load
    public func load(_ path: URL) {
        
        // load the content depending of the type
        do {
            // Check if this is a dir first. This will throw in case
            // the path does not exist
            let isDirectory = try isDirectory(path: path)
            
            // let's work with this dir/file if it exists
            if isDirectory {
                type = .directory
                
                // reset the stack
                resetStack()
                let fileItemType: FileItemType = type == .directory ? .directory : .archive
                let fileItem = FileItem(path: path, type: fileItemType)
                stack.push(fileItem)
                
                try loadDirectoryContent(path: path)
            } else {
                // no dir, check if this is a supported archive
                let ext = path.pathExtension
                let isSupportedArchive = isSupportedArchive(ext: ext)
                if isSupportedArchive {
                    type = .archive
                    
                    // reset the stack
                    resetStack()
                    let fileItemType: FileItemType = type == .directory ? .directory : .archive
                    let fileItem = FileItem(path: path, type: fileItemType)
                    stack.push(fileItem)
                    
                } else {
                    print("no need to change anything as a file was tried to be loaded")
                    errorMessage = "This file type is not supported by MacPacker"
                }
            }
            
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
    
    public func open(_ item: FileItem) {
        let exists = isExists(path: item.path)
        if !exists {
            errorMessage = "The selected file does not exist"
            return
        }
        
        do {
            switch item.type {
            case .file:
                // open external
                break
            case .directory:
                try loadDirectoryContent(path: item.path)
                if item.name == ".." {
                    _ = stack.pop()
                } else {
                    stack.push(item)
                }
            case .archive:
                // extract and load directory
                break
            }
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
        
        print(stack)
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
    
    /// Checks if the given file exists
    /// - Parameter path: URL to check for existance
    /// - Returns: true in case the file/dir on that path exists, false otherwise
    public func isExists(path: URL) -> Bool {
        if #available(macOS 13.0, *) {
            if FileManager.default.fileExists(atPath: path.path()) {
                return true
            }
        } else {
            if FileManager.default.fileExists(atPath: path.path) {
                return true
            }
        }
        return false
    }
    
    /// Checks if the given path is a directory
    /// - Parameter path: path to the potential directory
    /// - Returns: true in case the path is a dir, false otherwise
    public func isDirectory(path: URL) throws -> Bool {
        var isDirectory: ObjCBool = false
        if #available(macOS 13.0, *) {
            if !FileManager.default.fileExists(atPath: path.path(), isDirectory: &isDirectory) {
                throw CocoaError(.fileNoSuchFile)
            }
        } else {
            if !FileManager.default.fileExists(atPath: path.path, isDirectory: &isDirectory) {
                items = []
                throw CocoaError(.fileNoSuchFile)
            }
        }
        
        return isDirectory.boolValue
    }
    
    // Loads the contents of the directory/archive
    private func loadDirectoryContent(path: URL) throws {
        let contents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: [.isDirectoryKey])
        var resultItems: [FileItem] = []
        
        // add the possibility to go up
        resultItems.append(FileItem(path: path.deletingLastPathComponent(), type: .directory, name: ".."))
        
        // now add all items in the dir
        for url in contents {
            var isDirectory = false
            do {
                let resourceValue = try url.resourceValues(forKeys: [.isDirectoryKey, .totalFileSizeKey])
                isDirectory = resourceValue.isDirectory ?? false
            } catch {
                
            }
            
            let fileItemType: FileItemType = isDirectory ? .directory : .file
            let fileItem = FileItem(path: url, type: fileItemType)
            
            resultItems.append(fileItem)
        }
        items = resultItems.sorted {
            if $0.type == $1.type {
                return $0.name < $1.name
            }
            
            return $0.type > $1.type
        }
        print("items loaded \(items.count)")
    }
    
    private func resetStack() {
        self.stack.clear()
    }
}
