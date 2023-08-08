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

enum SupportedArchiveTypes {
    case lz4
    case tar
}

class FileContainer: ObservableObject {
    @Published var path: URL?
    @Published var type: ContainerType = .none
    @Published var items: [FileItem] = []
    @Published var errorMessage: String?
    
    //
    // Initializers
    //
    
    // Default constructor
    init() {
    }
    
    //
    // Functions
    //
    
    // loads a new container
    public func load(path: URL) {
        self.path = path
        var isDirectory: ObjCBool = false
        if #available(macOS 13.0, *) {
            if !FileManager.default.fileExists(atPath: path.path(), isDirectory: &isDirectory) {
                items = []
                return
            }
        } else {
            if !FileManager.default.fileExists(atPath: path.path, isDirectory: &isDirectory) {
                items = []
                return
            }
        }
        
        // load the content depending of the type
        do {
            if isDirectory.boolValue {
                type = .directory
                try loadDirectoryContent()
            } else {
                type = .archive
            }
        } catch let error as CocoaError {
            switch error.code {
            case .fileReadNoPermission, .fileReadUnknown:
                print("no access")
                errorMessage = "MacPacker does not have access to the parent directory."
            default:
                print("unknown CocoaError")
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    // Loads the contents of the directory/archive
    private func loadDirectoryContent() throws {
        if let path = self.path {
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
    }
}
