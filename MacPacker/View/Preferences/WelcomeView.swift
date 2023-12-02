//
//  WelcomeView.swift
//  MacPacker
//
//  Created by Arenswald, Stephan (059) on 22.09.23.
//

import Foundation
import SwiftUI

struct WelcomeWhatsNewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("• feat: multiple windows support")
            Text("• fix: open with in Finder not working")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}

struct WelcomeOtherProjects: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image("Braindump")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .cornerRadius(5)
                    .padding(4)
                Link(destination: URL(string: "https://getbraindump.app/?ref=mpwelcome")!) {
                    Text("Braindump")
                }
                Text("When you need to write down thoughts. Fast.")
            }
            HStack(alignment: .center) {
                Image("FileFillet")
                    .resizable()
                    .frame(width: 32, height: 32)
                Link(destination: URL(string: "https://filefillet.com/?ref=mpwelcome")!) {
                    Text("FileFillet")
                }
                Text("Organize files without tons of Finder windows.")
            }
            
            HStack(alignment: .center) {
                Image("")
                    .resizable()
                    .frame(width: 32, height: 32)
                Link(destination: URL(string: "https://lemonbuilder.sarensx.com/?ref=mpwelcome")!) {
                    Text("LemonBuilder")
                }
                Text("Because hosting simple websites should be free. (in development)")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}

struct WelcomeFeedbackView: View {
    @State private var feedbackText: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                ZStack {
                    if feedbackText.isEmpty {
                        VStack {
                            Text("Please support the archive type ...")
                            Text("I found the following bug")
                            Text("Please add feature ...")
                        }
                    }
                    TextEditor(text: $feedbackText)
                        .frame(maxHeight: .infinity)
                        .opacity(feedbackText.isEmpty ? 0.25 : 1)
                }
                Button("Send") {
                    var urlc = URLComponents(string: "mailto:hej@sarensx.com")
                    urlc?.queryItems = [
                        URLQueryItem(name: "subject", value: "MacPacker Feedback \(UUID())"),
                        URLQueryItem(name: "body", value: feedbackText)
                    ]
                    if let url = urlc?.url {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
            
            Spacer()
            HStack(spacing: 14) {
                Text("Or reach out via...")
                Link("hej@sarensx.com", destination: URL(string: "mailto:hej@sarensx.com")!)
                Link("@sarensw", destination: URL(string: "https://twitter.com/sarensw")!)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}

struct WelcomeView: View {
    @Environment(\.openURL) private var openURL
    @State private var defaultTab = 1

    var body: some View {
        VStack (alignment: .center, spacing: 8) {
            Group {
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, alignment: .center)
                Text("Welcome to")
                    .font(.system(size: 42, weight: .medium, design: .default))
                    .foregroundColor(.secondary) +
                Text(" MacPacker")
                    .font(.system(size: 42, weight: .medium, design: .default))
                Text("Version v\(Bundle.main.appVersionLong)")
                    .foregroundColor(.secondary)
            }
            
            TabView(selection: $defaultTab) {
                WelcomeWhatsNewView()
                    .tabItem {
                        Text("What's new")
                    }
                    .tag(1)
                WelcomeOtherProjects()
                    .tabItem {
                        Text("More projects")
                    }
                    .tag(2)
                WelcomeFeedbackView()
                    .tabItem {
                        Text("Feedback")
                    }
                    .tag(3)
            }
            .tabViewStyle(.automatic)
            .padding(.top, 16)
            
            #if !STORE
            Text("Support this Open Source project...")
                .fontWeight(.semibold)
                .padding(.top, 14)
            HStack {
                Image("BuyMeCoffee")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 32)
                    .onTapGesture {
                        openURL(URL(string: "https://www.buymeacoffee.com/sarensw")!)
                    }
                Image("Paypal")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 32)
                    .onTapGesture {
                        openURL(URL(string: "https://www.paypal.com/donate/?hosted_button_id=KM8GA7MJMYNQN")!)
                    }
            }
            #else
            Spacer()
            #endif
            
            
//            Text("2023 SarensX OÜ, Stephan Arenswald. Published as Open Source under GPL.")
//                .font(.footnote)
//                .foregroundColor(.secondary)
//                .padding(.top, 14)
        }
        .padding()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .frame(width: 480, height: 480)
    }
}
