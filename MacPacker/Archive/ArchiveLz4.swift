//
//  ArchiveLz4.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 08.08.23.
//

import Foundation
import AppleArchive
import System

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

class ArchiveLz4: Archive {
    var ext: String = "lz4"
    var extractedPath: URL? = nil
    var item: FileItem
    
    init(_ item: FileItem) {
        self.item = item
    }
    
    func content() throws -> [FileItem] {
        print("archive content")
        
        // lz4 is just a compression algorithm. So the content
        // is the name of the file without the extension
        if item.ext == ext {
            if let name = item.path?.lastPathComponent.dropLast(ext.count + 1) {
                return [
                    FileItem.parent,
                    FileItem(name: String(name), type: .file)
                ]
            }
        }
        
        throw ArchiveError.invalidArchive("This is supposed to be a lz4 archive, but it does not end with \(ext)")
    }
    
    /// Extracts this archive to a temporary location in the sandbox
    /// - Returns: the directory as a file item to further process this
    func extractToTemp() -> FileItem? {
        if let tempUrl = createTempDirectory(),
           let sourceFilePath = item.path {
            
            let sourceFileName = sourceFilePath.lastPathComponent
            let extractedFileName = String(sourceFileName.dropLast(ext.count + 1))
            let extractedFilePathName = tempUrl.appendingPathComponent(extractedFileName, isDirectory: false)
            extractedPath = tempUrl
            
            print("--- Extracting...")
            print("source: \(sourceFileName)")
            print("target: \(extractedFileName)")
            print("target: \(extractedFilePathName)")
            
            guard let readFileStream = ArchiveByteStream.fileStream(
                path: FilePath(item.path!.path),
                mode: .readOnly,
                options: [ ],
                permissions: FilePermissions(rawValue: 0o644)) else {
                return nil
            }
            guard let writeFileStream = ArchiveByteStream.fileStream(
                path: FilePath(String(extractedFilePathName.path)),
                mode: .writeOnly,
                options: [ .create ],
                permissions: FilePermissions(rawValue: 0o644)) else {
                return nil
            }
            guard let decompressStream = ArchiveByteStream.decompressionStream(readingFrom: readFileStream) else {
                print("unable to create compress stream")
                return nil
            }
            
            do {
                _ = try ArchiveByteStream.process(readingFrom: decompressStream,
                                                  writingTo: writeFileStream)
            } catch {
                print("Handle `ArchiveByteStream.process` failed.")
            }

            defer {
                try? readFileStream.close()
                try? writeFileStream.close()
            }
            
            print("---")
        }
        
        return FileItem(name: "dir", type: .directory)
    }
}
