//
//  Store.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 23.11.23.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    static var shared: AppState = AppState()
    
    private init() { }
}
