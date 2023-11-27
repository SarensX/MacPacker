//
//  InternalEditorView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 22.11.23.
//

import Foundation
import SwiftUI

struct InternalEditorView: View {
    @EnvironmentObject private var viewEnvObj: TestEvObj
    @State var fileContent: String = ""
    var text: String = "" {
        didSet {
            fileContent = text
        }
    }
    
    var body: some View {
        HStack {
            TextEditor(text: .constant(viewEnvObj.text))
                .font(Font.callout.monospaced())
        }
        .frame(width: 600, height: 600)
        .padding()
    }
}
