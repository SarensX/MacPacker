//
//  ItemTableView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 04.08.23.
//

import Foundation
import AppKit
import SwiftUI

struct ItemTableView: NSViewRepresentable {
//    @Binding var items: [FileItem]
    @Binding var container: FileContainer
    @Binding var selectedFile: Set<FileItem.ID>
    
    func makeNSView(context: Context) -> NSScrollView {
        let tableView = NSTableView()
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.doubleAction = #selector(Coordinator.doubleClickedRow(_:))
//        tableView.headerView = nil
        tableView.target = context.coordinator
//        tableView.allowsTypeSelect = false
        tableView.allowsMultipleSelection = true
        
        let nameColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "name"))
        nameColumn.title = "Name"
        nameColumn.width = 450
        tableView.addTableColumn(nameColumn)
        
        let sizeColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "size"))
        sizeColumn.title = "Size"
        sizeColumn.width = 100
        tableView.addTableColumn(sizeColumn)
        
//        self.tableView = tableView
        
        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        
        let objectController = NSObjectController()
        objectController.addObserver(context.coordinator, forKeyPath: "items", options: [.new, .old], context: nil)
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        print("updateNSView")
//        context.coordinator.items = items
        guard let tableView = nsView.documentView as? NSTableView else { return }
        tableView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(container: $container, selectedFile: $selectedFile)
    }
    
    final class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
        @Binding var container: FileContainer
        @Binding var selectedFile: Set<FileItem.ID>

        init(container: Binding<FileContainer>, selectedFile: Binding<Set<FileItem.ID>>) {
            _container = container
            _selectedFile = selectedFile
        }
        
        func numberOfRows(in tableView: NSTableView) -> Int {
            return container.items.count
        }
        
        @objc func doubleClickedRow(_ sender: AnyObject) {
            if let tableView = sender as? NSTableView {
                let clickedRow = tableView.clickedRow
                if clickedRow >= 0 && clickedRow < container.items.count {
                    let file = container.items[clickedRow]
                    print("Double Clicked: \(file.name), \(String(describing: file.size))")
                }
            }
        }

        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            print("tableView")
            guard let columnIdentifier = tableColumn?.identifier else { return nil }
            let item = container.items[row]

            if let cell = tableView.makeView(withIdentifier: columnIdentifier, owner: nil) as? NSTextField {
                cell.stringValue = columnIdentifier.rawValue == "name" ? item.name : String(item.size ?? 0)
                return cell
            }

            let cell = NSTextField()
            cell.identifier = columnIdentifier
            cell.isBordered = false
            cell.isBezeled = false
            cell.isEditable = false
            cell.drawsBackground = false
            cell.stringValue = columnIdentifier.rawValue == "name" ? item.name : String(item.size ?? 0)
            print(item.name)

            return cell
        }

        func tableViewSelectionDidChange(_ notification: Notification) {
            print("tableViewSelectionDidChange")
            let tableView = notification.object as! NSTableView
            let selectedRow = tableView.selectedRow
            if selectedRow >= 0 && selectedRow < container.items.count {
                selectedFile = [container.items[selectedRow].id]
            } else {
                selectedFile = []
            }
        }
    }
}
