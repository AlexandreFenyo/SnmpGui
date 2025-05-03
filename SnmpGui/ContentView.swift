//
//  ContentView.swift
//  SnmpGui
//
//  Created by Alexandre Fenyo on 13/04/2025.
//

import SwiftUI

// https://developer.apple.com/documentation/swiftui/outlinegroup
// fenyo@mac ~ % snmpwalk -v2c -OT -OX -c public 192.168.0.254 > /tmp/snmpwalk.res

struct OIDTreeView: View {
    @ObservedObject var node: OIDNodeDisplayable
    
    var body: some View {
        if node.children == nil || node.children?.isEmpty == true {
            // no children
            HStack(alignment: .top) {
                VStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                    // .padding(.trailing, 5)
                }
                VStack {
                    HStack(alignment: .top) {
                        Text(node.getDisplayValAndSubValues())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(node.subnodes.last?.val ?? "empty val").font(.subheadline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .onTapGesture {
                print(node.line)
            }
            
            
        }
        else {
            // children exist
            DisclosureGroup(isExpanded: $node.isExpanded, content: {
                if let children = node.children {
                    ForEach(children) { child in
                        OIDTreeView(node: child)
                    }
                }
            }) {
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.orange)
                    Text(node.getDisplayValAndSubValues())
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var text: String = ""
    @StateObject var rootNode: OIDNodeDisplayable
    
    var body: some View {
        VStack {
            Button("Reload") {
                rootNode.children?.removeAll()
            }
            NavigationView {
                List {
                    OIDTreeView(node: rootNode)
                }
                .navigationTitle("Arbre")
            }
            
        }
    }
}
