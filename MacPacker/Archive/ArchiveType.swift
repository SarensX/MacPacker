//
//  Archive.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 09.10.23.
//

import Foundation

struct ArchiveType {
    public static func with(_ type: String) throws -> IArchiveType {
        if type == "lz4" { return ArchiveTypeLz4() }
        if type == "tar" { return ArchiveTypeTar() }
        if type == "zip" { return ArchiveTypeZip() }
        if type == "7z" { return ArchiveType7zip() }
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
