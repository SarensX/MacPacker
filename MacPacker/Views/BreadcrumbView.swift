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
    
    init(url: URL?) {
        self.url = url
        if let url {
            var tempUrl: URL?
            for i in 0..<url.pathComponents.count {
                // name
                let component = url.pathComponents[i]
                
                // current url
                if tempUrl == nil {
                    tempUrl = URL(fileURLWithPath: "/")
                } else {
                    tempUrl = tempUrl?.appending(component: component)
                }
                
                // icon
                var icon: NSImage?
                if let tempUrl {
                    icon = getNSImage(url: tempUrl)
                }
                
                // create the bi
                let bi = BreadcrumbItem(
                    icon: icon,
                    name: component)
                items.append(bi)
            }
        }
    }
    
    func getNSImage(url: URL) -> NSImage? {
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        print(url.path)
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
