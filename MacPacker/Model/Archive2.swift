//
//  Archive2.swift
//  MacPacker
//
//  Created by Arenswald, Stephan on 24.09.23.
//

import Foundation

enum Archive2Error: Error {
    case unknownType(String)
}

enum Archive2Type: String {
    case tar = "tar"
    case zip = "zip"
    case lz4 = "lz4"
}

/// Unused yet, but will be used in future to replace FileContainer
class Archive2 {
    @Published var url: URL?
    @Published var internalPath: String = "/"
    @Published var type: Archive2Type
    @Published var stack: ArchiveItemStack = ArchiveItemStack()
    @Published var items: [ArchiveItem] = []
    @Published var canEdit: Bool = false
    @Published var tempDirs: [URL] = []
    
    //
    // Initializers
    //
    
    /// Default constructor
    init() {
        url = nil
        type = .zip
        canEdit = true
    }
    
    /// Constructor use if loading an archive
    init(url: URL) throws {
        self.url = url
        self.type = .zip
        type = try determineTypeFrom(url: url)
        if isSupportedType(url: url) == false {
            throw Archive2Error.unknownType("Type \(type) is not supported yet")
        }
        if type == .zip {
            canEdit = true
        }
        try load(url)
    }
    
    /// Starts all the required observers for the file container
    private func startObserver() {
        NotificationCenter.default.addObserver(forName: Notification.Name("file.load"), object: nil, queue:
        nil) {
            notification in
            if let paths = notification.object as? [URL] {
                if paths.count > 0 {
//                    self.load(paths[0])
                }
            }
        }
    }
    
    //
    // Description
    //
    
    public var description: String {
        var result = "> \(String(describing: url))\n"
        result = result + "  type: \(type)"
        return result
    }
    
    //
    // Functions
    //
    
    /// Cleans up all the temporary dirs created during the extraction process
    public func clean() throws {
        for tempDir in tempDirs {
            try FileManager.default.removeItem(at: tempDir)
        }
        tempDirs.removeAll()
    }
    
    /// Determines the archive type for the given file url
    /// - Parameter url: file url
    /// - Returns: archive type
    private func determineTypeFrom(url: URL) throws -> Archive2Type {
        let ext = url.pathExtension
        if ext == "" { throw Archive2Error.unknownType("Unknown type") }
        
        guard let at = Archive2Type(rawValue: ext) else {
            throw Archive2Error.unknownType("Unknown type")
        }
        
        return at
    }
    
    /// Checks whether the given URL is leads to a supported archive type
    /// - Parameter url: url to check
    /// - Returns: true in case the archive is supported, false otherwise
    private func isSupportedType(url: URL) -> Bool {
        do {
            _ = try determineTypeFrom(url: url)
            return true
        } catch { }
        return false
    }
    
    /// Adds the given files to the archive. Note that this only works for editable archives
    /// - Parameter urls: the urls of the files to add
    func add(urls: [URL]) {
        if canEdit == false { return }
        
        for url in urls {
            items.append(ArchiveItem(path: url, type: .file))
        }
    }
    
    /// Saves the current list of items to the given URL as an archvie
    /// - Parameter url: the url where to save the archive
    func save(to url: URL) throws {
        if canEdit == false { return }
        
        let at = try ArchiveType.with(type.rawValue)
        try at.save(to: url, items: items)
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
//                try loadDirectoryContent(path: entry.localPath)
            }
            
            // stack item is archive
            if let archivePath = entry.archivePath,
               let archiveType = entry.archiveType {
                let archive = try ArchiveType.with(archiveType)
                
                if let content: [ArchiveItem] = try? archive.content(
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
//            if clear { resetStack() }
            if push { stack.push(entry) }
            FileContainer.currentStackEntry = entry
            
//            isReloadNeeded = true
        } catch {
            print(error)
        }
        
        print(stack.description)
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
    
    /// Loads the archive from the given url
    /// - Parameter url: archive url
    func load(_ url: URL) throws {
        let stackEntry = ArchiveItemStackEntry(
            type: .Archive,
            localPath: url,
            archivePath: "",
            tempId: nil,
            archiveType: url.pathExtension)
        loadStackEntry(stackEntry, clear: true)
    }
    
    /// Opens the given item. This can be one of the following cases:
    /// - File in directory > open the file with system default action
    /// - Directory > show the content of the directory
    /// - Archive > show the content of the archive depending on the archive type
    /// - File in archive > extract just this file if possible, then open it with system default
    /// - Directory in archive > go one level down in archive if this is supported, otherwise, extract and then go to directory
    /// - Parameter item: The item to open
    func open(_ item: ArchiveItem) throws {
        // if the selected item is the parent item (the one with ..),
        // then just go back in the stack
        if item == ArchiveItem.parent {
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
                                let stackEntry = ArchiveItemStackEntry(
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
                           let tempDir = try? ArchiveType
                            .with(archiveType)
                            .extractFileToTemp(
                                path: currentStackEntry.localPath,
                                item: item) {
                            
                            // now, create the new stack entry
                            let stackEntry = ArchiveItemStackEntry(
                                type: .Archive,
                                localPath: tempDir,
                                archivePath: "",
                                tempId: nil,
                                archiveType: item.ext)
                            loadStackEntry(stackEntry)
                            
                            // adds the newly created temp dir to the list of temp dirs. This
                            // is required to clean them up later.
                            if tempDir.isDirectory {
                                tempDirs.append(tempDir)
                            } else {
                                var td = tempDir
                                td.deleteLastPathComponent()
                                tempDirs.append(td)
                            }
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
                let stackEntry = ArchiveItemStackEntry(
                    type: .Archive,
                    localPath: currentStackEntry.localPath,
                    archivePath: archivePath == "" ? item.name : archivePath + "/" + item.name,
                    tempId: currentStackEntry.tempId,
                    archiveType: currentStackEntry.archiveType)
                loadStackEntry(stackEntry)
            }
        }
    }
}
