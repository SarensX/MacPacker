//
//  PreferencesView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 02.12.23.
//

import Foundation
import SwiftUI

struct PreferencesView: View {
    var body: some View {
        VStack {
            TabView {
                SettingsGeneralView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("General")
                    }
                    .tag(0)
            }
        }
        .frame(width: 640)
        .onAppear {
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
}
