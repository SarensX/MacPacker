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
    @Published var tempArchives: [Archive] = []
    
    //
    // Initializers
    //
    
    // Default constructor
    init() {
    }
    
    //
    // Functions
    //
    
    /// Loads the directory/archive/file from the given path. This is done when you drag/drop an
    /// item to the window or when you open an item using the open dialog
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
                let fileItem = FileItem(path: path, type: .directory)
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
                    let fileItem = FileItem(path: path, type: .archive)
                    stack.push(fileItem)
                    
                    try loadArchiveContent(fileItem)
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
        // if the selected item is the parent item (the one with ..),
        // then just go back in the stack
        if item == FileItem.parent {
            stack.pop()
            if let parent = stack.pop() {
                open(parent)
            }
            return
        }
        
        // if an item in an archive was selected that is not extracted yet,
        // then extract, and then jump into the extracted dir
        if item.path == nil {
            if let parent = stack.peek() {
                if parent.type == .archive {
                    if let archive = tempArchives.first(where: { $0.item.id == parent.id }) {
                        if let fileItem = archive.extractToTemp() {
                            open(fileItem)
                        }
                        
                        // if it was decompressed then the output is a file or archive
                        // in case of a file > open
                        // in case of an archive > content
                        
                        // if it was extracted, then show the content of the directory
                    }
                    return
                }
            }
            return
        }
        
        // if a regular item in a directory was selected, then check the type
        if let path = item.path {
            print("----")
            print(path.path)
            print(FileManager.default.fileExists(atPath: path.path))
            let exists = isExists(path: path)
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
                    try loadDirectoryContent(path: path)
                    if item.name == ".." {
                        stack.pop()
                    } else {
                        stack.push(item)
                    }
                case .archive:
                    // extract and load directory
                    try loadArchiveContent(item)
                    stack.push(item)
                case .unknown:
                    self.errorMessage = "unknown type"
                }
            } catch {
                print(error)
                errorMessage = error.localizedDescription
            }
            
            print(stack)
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
        var archive: Archive? = nil
        if item.ext == SupportedArchiveTypes.lz4.rawValue {
            archive = ArchiveLz4(item)
        } else if item.ext == SupportedArchiveTypes.tar.rawValue {
            archive = ArchiveTar(item)
        }
        
        if let archive {
            items = try archive.content().sorted {
                if $0.type == $1.type {
                    return $0.name < $1.name
                }
                
                return $0.type > $1.type
            }
            tempArchives.append(archive)
        }
    }
    
    private func resetStack() {
        self.stack.clear()
    }
}
