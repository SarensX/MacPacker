//
//  Archive.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 22.08.23.
//

import Foundation

protocol Archive {
    var ext: String { get }
    var extractedPath: URL? { get }
    var item: FileItem { get }
    
    func content() throws -> [FileItem]
    func extractToTemp() -> FileItem?
}

extension Archive {
    public func createTempDirectory() -> URL? {
        do {
            let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let id = UUID().uuidString
            let appSupportSubDirectory = applicationSupport
                .appendingPathComponent("ta", isDirectory: true)
                .appendingPathComponent(id, isDirectory: true)
            try FileManager.default.createDirectory(at: appSupportSubDirectory, withIntermediateDirectories: true, attributes: nil)
            print(appSupportSubDirectory.path) // /Users/.../Library/Application Support/YourBundleIdentifier
            return appSupportSubDirectory
        } catch {
            print(error)
        }
        return nil
    }
}

enum ArchiveError: Error {
    // used to say that the archive is invalid and cannot be extracted
    case invalidArchive(_ message: String)
}

