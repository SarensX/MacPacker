//
//  ArchiveItemStackEntry.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 09.10.23.
//

import Foundation

enum ArchiveItemStackEntryType {
    case Directory
    case Archive
}

struct ArchiveItemStackEntry {
    // type of item
    let type: ArchiveItemStackEntryType
    
    // path can be one of:
    // - path on local drive to file
    // - path on local drive to directory
    // - path in archive to file, not extracted
    // - path in archive to directory, not extracted
    // - path in archive to file, extracted archive
    // - path in archive to directory, extracted archive
//    private var path: String
    
    // This path contains the URL to the actual file
    // or directory on the local drive. In case we are
    // navigating in an archive right now, this url stays
    // the same
    let localPath: URL
    
    // path in the archive
    let archivePath: String?
    
    // id of the temporary extraction path
    let tempId: String?
    
    // type of the archive (to find the implementation quickly)
    let archiveType: String?
}

extension ArchiveItemStackEntry: CustomStringConvertible {
    var description: String {
        var result = "> " + localPath.absoluteString + "\n"
        result = result + "  type: \(type) \n"
        result = result + "  archivePath: \(archivePath ?? "undefined") \n"
        result = result + "  tempId: \(tempId ?? "undefined") \n"
        result = result + "  archiveType: \(archiveType ?? "undefined") \n"
        
        return result
    }
}
