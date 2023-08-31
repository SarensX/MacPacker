//
//  ArchiveTableView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 30.08.23.
//

import Foundation
import AppKit
import SwiftUI

/// Coordinator for the table
final class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var parent: ArchiveTableView
    var items: [FileItem] = []
    
    init(_ parent: ArchiveTableView) {
        self.parent = parent
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        print("number of rows changed to \(items.count)")
//        return parent.data.count
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let columnIdentifier = tableColumn?.identifier else { return nil }
        
        let cellView = NSTableCellView()
        cellView.identifier = columnIdentifier
        cellView.backgroundStyle = .raised
        let textField = NSTextField(labelWithString: items[row].name)
        cellView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        
        return cellView
    }
}

/// Table
struct ArchiveTableView: NSViewRepresentable {
    @Binding var data: [FileItem]
    @Binding var isReloadNeeded: Bool
    
    //
    // Constructor
    //
    
//    init(_ data: Binding<FileContainer>) {
//        _data = data
//    }
    
    //
    // NSViewRepresentable
    //
    
    /// makeNSView
    /// - Parameter context: context
    /// - Returns: desc
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let tableView = NSTableView()
        // make sure the table is scrollable
        scrollView.documentView = tableView
        
        // set up the table
        createColumns(tableView)
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.style = .fullWidth
        tableView.allowsMultipleSelection = true
        tableView.usesAlternatingRowBackgroundColors = true
        
        return scrollView
    }
    
    /// updateNSView
    /// - Parameters:
    ///   - nsView: desc
    ///   - context: context
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        // todo: make sure the data is only reloaded when needed
        if isReloadNeeded {
            print("reload needed")
            let tableView = (nsView.documentView as! NSTableView)
            //        context.coordinator.parent = self
            context.coordinator.items = self.data
            DispatchQueue.main.async {
                tableView.reloadData()
                isReloadNeeded = false
            }
        } else {
            print("reload not needed")
        }
    }
    
    /// create the coordinator
    /// - Returns: coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    //
    // Table related setup
    //
    
    func createColumns(_ tableView: NSTableView) {
        let colName = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "name"))
        colName.title = "Name"
        tableView.addTableColumn(colName)
    }
    
    //
    // Table delegate
    //
}