//
//  Archive.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 09.10.23.
//

import Foundation

struct Archive {
    public static func with(_ type: String) throws -> IArchive {
        if type == "lz4" { return ArchiveLz4() }
        if type == "tar" { return ArchiveTar() }
        if type == "zip" { return ArchiveZip() }
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
