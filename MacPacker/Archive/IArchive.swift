//
//  Archive.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 22.08.23.
//

import Foundation

protocol IArchive {
    var ext: String { get }
    var extractedPath: URL? { get }
    var item: FileItem? { get }
    
    func content(path: URL, archivePath: String) throws -> [FileItem]
    func extractToTemp(path: URL) -> URL?
    func extractFileToTemp(path: URL, item: FileItem) -> URL?
}

struct Archive {
    public static func with(_ type: String) throws -> IArchive {
        if type == "lz4" { return ArchiveLz4() }
        if type == "tar" { return ArchiveTar() }
        throw ArchiveError.invalidArchive("Unknown archive type \(type)")
    }
    
    public static func getTempDirectory(id: String) -> URL {
        let applicationSupport = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let appSupportSubDirectory = applicationSupport
            .appendingPathComponent("ta", isDirectory: true)
            .appendingPathComponent(id, isDirectory: true)
        return appSupportSubDirectory
    }
}

extension IArchive {
    public func stripFileExtension ( _ filename: String ) -> String {
        var components = filename.components(separatedBy: ".")
        guard components.count > 1 else { return filename }
        components.removeLast()
        return components.joined(separator: ".")
    }
    
    public func createTempDirectory() -> (id: String, path: URL)? {
        do {
            let applicationSupport = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let id = UUID().uuidString
            let appSupportSubDirectory = applicationSupport
                .appendingPathComponent("ta", isDirectory: true)
                .appendingPathComponent(id, isDirectory: true)
            try FileManager.default.createDirectory(at: appSupportSubDirectory, withIntermediateDirectories: true, attributes: nil)
            print(appSupportSubDirectory.path) // /Users/.../Library/Application Support/YourBundleIdentifier
            return (id, appSupportSubDirectory)
        } catch {
            print(error)
        }
        return nil
    }
    
    func nextPathComponent(after archivePath: String, in containerPath: String) -> (name: String, isDirectory: Bool)? {
        // Ensure that the containerPath starts with the archivePath
        guard containerPath.hasPrefix(archivePath) else {
            return nil
        }
        
        // Get the remaining path components after archivePath
        let remainingPath = containerPath.dropFirst(archivePath.count)
        
        // Split the remaining path components by "/"
        let pathComponents = remainingPath.split(separator: "/")
        
        // The next path component is the first one after archivePath
        guard let nextPathComponent = pathComponents.first else {
            return nil
        }
        
        // Check if the next path component is a directory
        let isDirectory = pathComponents.count > 1 || remainingPath.hasSuffix("/")
        
        if isDirectory {
            // Return the directory name
            return (String(nextPathComponent), true)
        } else {
            // Return the last path element (file name)
            return (String(pathComponents.last.map { String($0) }!), false)
        }
    }
}

enum ArchiveError: Error {
    // used to say that the archive is invalid and cannot be extracted
    case invalidArchive(_ message: String)
}

