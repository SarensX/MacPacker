//
//  Url+Extensions.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 11.10.23.
//

import Foundation

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
