//
//  ArchiveTar.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 22.08.23.
//

import Foundation
import SWCompression

class ArchiveTar: IArchive {
    var ext: String = "tar"
    var extractedPath: URL? = nil
    var item: FileItem?
    
    init() {
        
    }
    
    init(_ item: FileItem) {
        self.item = item
    }
    
    /// Returns the content of the tar file in form of FileItems. There is no need to extract the tar
    /// file because it allows us to peek into the tar file and get the content.
    /// - Parameters:
    ///   - path: Path to the tar file
    ///   - archivePath: Path within the tar archive to return
    /// - Returns: Items in the archive with the given path
    public func content(path: URL, archivePath: String) throws -> [FileItem] {
        var result: [FileItem] = [FileItem.parent]
        var dirs: [String] = []
        
        do {
            if let data = try? Data(contentsOf: path, options: .mappedIfSafe) {
                print("data loaded")
                
                let entries = try TarContainer.open(container: data)
                entries.forEach { tarEntry in
//                    print(tarEntry.info.name)
//                    print(tarEntry.info.type)
                    
                    // We shall only return what is in the archive path.
                    // The root of the archive path is always empty
//                    let archivePathComponents = archivePath.components(separatedBy: "/")
//                    let entryNameComponents = tarEntry.info.name.components(separatedBy: "/")
//                    for (i, component) in archivePathComponents.enumerated() {
//                        if entryNameComponents[i] == component && i == archivePathComponents.count - 1 {
//                            entryNameComponents
//                        }
//                    }
                    if let npc = nextPathComponent(after: archivePath, in: tarEntry.info.name) {
                        if npc.isDirectory {
                            if dirs.contains(where: { $0 == npc.name }) {
                                // added already, ignore
                            } else {
                                dirs.append(npc.name)
                                
                                result.append(FileItem(
                                    name: npc.name,
                                    type: .directory,
                                    virtualPath: archivePath + "/" + npc.name,
                                    size: nil))
                            }
                        } else {
                            if let name = npc.name.components(separatedBy: "/").last {
                                result.append(FileItem(
                                    name: name,
                                    type: .file,
                                    virtualPath: tarEntry.info.name))
                            }
                        }
                    }
                }
            }
        } catch {
            print("tar.content ran in error")
            print(error)
        }
        
        return result
    }
    
    func extractToTemp(path: URL) -> String? {
        print("extract tar")
        return nil
    }
    
    
}
