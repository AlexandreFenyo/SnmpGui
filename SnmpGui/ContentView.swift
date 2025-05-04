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
            // no child
            HStack(alignment: .top) {
                VStack {
                    if node.children_backup?.isEmpty == false {
                        Image(systemName: "folder")
                            .foregroundColor(.orange)
                    } else {
                        Image(systemName: "doc.text")
                            .padding(.trailing, 6)
                            .foregroundColor(.blue)
                    }
                }
                VStack {
                    HStack(alignment: .top) {
                        if node.children_backup?.isEmpty == false {
                            Text(node.getDisplayValAndSubValues())
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(node.subnodes.last?.val ?? "")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.trailing)
                        } else {
                            Text(node.getDisplayValAndSubValues())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(node.subnodes.last?.val ?? "")
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.trailing)
                        }
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
    @State private var filter: String = ""
    @StateObject var rootNode: OIDNodeDisplayable
    
    var body: some View {
        VStack {
            TextField("Entrez du texte ici", text: $filter)
                .autocorrectionDisabled(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: filter) { oldValue, newValue in
                    print("Texte saisi : \(newValue)")
//                    rootNode.children?.first?.hide()
                    rootNode.expandAll()
                    _ = rootNode.filter(newValue)
                }
            
            HStack {
                Button("Reload") {
                    withAnimation {
                        rootNode.children?.removeAll()
                    }
                }.border(.black)
                Button("expand all") {
                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                        rootNode.expandAll()
                    }
                }.border(.black)
                Button("collapse all") {
                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                        rootNode.collapseAll()
                    }
                }.border(.black)
            }
            List {
                OIDTreeView(node: rootNode)
            }
        }
    }
}
