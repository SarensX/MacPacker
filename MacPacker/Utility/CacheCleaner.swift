//
//  Cache.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 22.11.23.
//

import Foundation

class CacheCleaner {
    public static let shared: CacheCleaner = CacheCleaner()
    private let applicationSupportDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    
    func clean() {
        if let url = applicationSupportDirectory {
            do {
                try FileManager.default.removeItem(at: url.appendingPathComponent("ta", conformingTo: .directory))
            } catch {
                print("Could not clear cache because...")
                print(error)
            }
        }
    }
}
