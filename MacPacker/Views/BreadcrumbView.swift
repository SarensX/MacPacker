//
//  BreadcrumbView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 05.05.25.
//

import SwiftUI

struct BreadcrumbItem {
    var symbol: String = "document"
    var icon: NSImage?
    var name: String
}

struct BreadcrumbItemView: View {
    var breadcrumbItem: BreadcrumbItem
    var showName: Bool = true
    
    var body: some View {
        HStack(spacing: 2) {
            if let icon = breadcrumbItem.icon {
                Image(nsImage: icon)
                    .resizable(resizingMode: .stretch)
                    .frame(
                        width: 16,
                        height: 16)
            } else {
                Image(systemName: breadcrumbItem.symbol)
                    .frame(width: 16, height: 16)
            }
            if showName {
                Text(breadcrumbItem.name)
                    .lineLimit(1)
                    .fixedSize()
            }
        }
        .font(.callout)
    }
}

struct BreadcrumbView: View {
    private var url: URL?
    private var items: [BreadcrumbItem] = []
    
    init(archive: Archive2?) {
        if let archive, let archiveUrl = archive.url {
            items.append(BreadcrumbItem(
                icon: getNSImage(url: archiveUrl),
                name: archiveUrl.lastPathComponent
            ))
            
            for stackItem in archive.stack {
                var icon: NSImage?
                if stackItem.type == .Directory || stackItem.type == .ArchiveDirectory {
                    icon = NSWorkspace.shared.icon(for: .folder)
                } else {
                    icon = getNSImageByExtension(fileName: stackItem.name)
                }
                items.append(BreadcrumbItem(
                    icon: icon,
                    name: stackItem.name
                ))
            }
        }
    }
    
    func getNSImageByExtension(fileName: String) -> NSImage? {
        let fileExtension = (fileName as NSString).pathExtension
        let icon = NSWorkspace.shared.icon(forFileType: fileExtension)
        return icon
    }
    
    func getNSImage(url: URL) -> NSImage? {
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        print("Loading image for: \(url.path)")
        return icon
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline,spacing: 4) {
            ForEach(items.indices, id: \.self) { index in
                if index > 0 {
                    BreadcrumbItemView(breadcrumbItem: items[index])
                    
                    if index != items.indices.last {
                        Image(systemName: "chevron.compact.right")
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .frame(height: 24)
    }
}
