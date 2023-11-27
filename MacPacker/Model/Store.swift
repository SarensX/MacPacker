//
//  Store.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 23.11.23.
//

import Foundation
import SwiftUI

class Store: ObservableObject {
    @Published var archive: Archive2?
    @Published var selectedItem: ArchiveItem? = nil
}
