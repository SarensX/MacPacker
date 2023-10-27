//
//  Breadcrumb.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 24.10.23.
//

import Foundation

class Breadcrumbs: ObservableObject {
    @Published var completePathArray: [String] = []
    @Published var completePath: String?
    
    /// Default constructor
    init () {
        startObserver()
    }
    
    /// Starts all observers
    func startObserver() {
        NotificationCenter.default.addObserver(forName: Notification.Name("Breadcrumbs.update"), object: nil, queue: nil) { notification in
            if let url = notification.object as? URL {
                self.setPathFrom(url: url)
            }
        }
    }
    
    func setPathFrom(url: URL) {
        // convert the URL to a path and path array
        completePath = url.path
    }
}
