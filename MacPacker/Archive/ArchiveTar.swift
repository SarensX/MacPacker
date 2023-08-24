//
//  ArchiveTar.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 22.08.23.
//

import Foundation
import SWCompression

class ArchiveTar: Archive {
    var ext: String = "tar"
    var extractedPath: URL? = nil
    var item: FileItem
    
    init(_ item: FileItem) {
        self.item = item
    }
    
    func content() throws -> [FileItem] {
        print("content tar")
        
        var result: [FileItem] = []
        result.append(FileItem.parent)
        
        if let sourceFilePath = item.path {
            do {
                if let data = try? Data(contentsOf: sourceFilePath, options: .mappedIfSafe) {
                    print("data loaded")
                    
                    let entries = try TarContainer.open(container: data)
                    entries.forEach { tarEntry in
                        print(tarEntry.info.name)
                        print(tarEntry.info.type)
                        result.append(FileItem(
                            name: tarEntry.info.name,
                            type: tarEntry.info.type == .directory ? .directory : .file,
                            virtualPath: tarEntry.info.name,
                            size: tarEntry.info.size))
                    }
                }
            } catch {
                print("tar.content ran in error")
                print(error)
            }
        }
        return result
    }
    
    func extractToTemp() -> FileItem? {
        print("extract tar")
        return nil
    }
    
    
}
