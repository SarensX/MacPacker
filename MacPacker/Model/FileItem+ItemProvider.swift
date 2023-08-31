//
//  FileItem+ItemProvider.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 26.08.23.
//

import Foundation
import UniformTypeIdentifiers

extension FileItem {
    static var draggableType = UTType(exportedAs: "com.sarensx.MacPacker.file")
    
    var itemProvider: NSItemProvider {
        let provider = NSItemProvider()
        provider.registerFileRepresentation(
            forTypeIdentifier: UTType.fileURL.identifier,
            fileOptions: [],
            visibility: .all,
            loadHandler: { (completion: ((URL?, Bool, Error?) -> Void)) -> Progress? in
                if let se = FileContainer.currentStackEntry {
                    do {
                        // write the data to a file
                        print("1")
                        guard let archiveType = se.archiveType else {
                            completion(nil, false, nil)
                            return nil
                        }
                        print("2")
                        guard let path = try Archive.with(archiveType).extractFileToTemp(
                            path: se.localPath,
                            item: self) else {
                            completion(nil, false, nil)
                            return nil
                        }
                        print("3")
                        guard let archivePath = se.archivePath else {
                            completion(nil, false, nil)
                            return nil
                        }
                        
//                        guard let provider = NSItemProvider(contentsOf: path) else { return NSItemProvider() }
//                        return provider
                        print("completion about to start")
                        path.startAccessingSecurityScopedResource()
                        completion(path, false, nil)
                        path.stopAccessingSecurityScopedResource()
                    } catch {
                        print("could not create item provider")
                        print(error)
                        completion(nil, false, nil)
                    }
                } else {
                    completion(nil, false, nil)
                }
//                url.startAccessingSecurityScopedResource()
//                completion(url.absoluteURL, false, nil)
//                url.stopAccessingSecurityScopedResource()
                return nil
            })
        return provider
        
        
        
//        if let se = FileContainer.currentStackEntry {
//            do {
//                // write the data to a file
//                guard let archiveType = se.archiveType else { return NSItemProvider() }
//                guard let path = try Archive.with(archiveType).extractFileToTemp(
//                    path: se.localPath,
//                    item: self) else { return NSItemProvider() }
//                guard let archivePath = se.archivePath else { return NSItemProvider() }
//
//                guard let provider = NSItemProvider(contentsOf: path) else { return NSItemProvider() }
//                return provider
//            } catch {
//                print("could not create item provider")
//                print(error)
//            }
//        }
//        return NSItemProvider()
        
        
        
        
        
        
        
        
        
        
        
        
//        provider.suggestedName = self.name
//        provider.registerDataRepresentation(
//            forTypeIdentifier: UTType.fileURL.identifier,
//            visibility: .all) { (completionHandler) -> Progress? in
//                completionHandler(self.data, nil)
//
//            return nil
//        }
//        provider.registerFileRepresentation(
//            forTypeIdentifier: UTType.fileURL.identifier,
//            fileOptions: [.openInPlace],
//            visibility: .all,
//            loadHandler: { (completion: ((URL?, Bool, Error?) -> Void)) -> Progress? in
//                print("Test")
//                let se = FileContainer.currentStackEntry
//                if let url = FileContainer.currentStackEntry?.localPath {
//                    print("valid local path")
//                    print(url)
//                    url.startAccessingSecurityScopedResource()
//                    completion(url.absoluteURL, false, nil)
//                    url.stopAccessingSecurityScopedResource()
//                }
//                return nil
//        })
//        provider.registerDataRepresentation(forTypeIdentifier: Self.draggableType.identifier, visibility: .all) {
//            print("drag drop")
//            if data != nil {
//                print("data")
//                $0(data, nil)
//            } else {
//                print("data it null")
//            }
//            return nil
//
////            let encoder = JSONEncoder()
////            do {
////                let data = try encoder.encode(self)
////                $0(data, nil)
////            } catch {
////                $0(nil, error)
////            }
////            return nil
//        }
//        return provider
    }
}
