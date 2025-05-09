//
//  ContentView.swift
//  SnmpGui
//
//  Created by Alexandre Fenyo on 13/04/2025.
//

import SwiftUI
import WebKit

// https://developer.apple.com/documentation/swiftui/outlinegroup
// fenyo@mac ~ % snmpwalk -v2c -OT -OX -c public 192.168.0.254 > /tmp/snmpwalk.res

extension String {
    func ranges(of searchString: String) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var startIndex = self.startIndex
        
        while startIndex < self.endIndex,
              let range = self.range(of: searchString, options: .caseInsensitive, range: startIndex..<self.endIndex) {
            ranges.append(range)
            startIndex = range.upperBound
        }
        return ranges
    }
}

struct HighlightedTextView: View {
    let fullText: String
    let highlight: String
    let highlightColor: Color = .blue
    let highlightBackgroundColor: Color = .yellow

    init(_ fullText: String, highlight: String) {
        self.fullText = fullText
        self.highlight = highlight
    }

    var body: some View {
        let lowercasedFullText = fullText.lowercased()
        let lowercasedHighlight = highlight.lowercased()
        
        let ranges = lowercasedFullText.ranges(of: lowercasedHighlight)
        
        var highlightedText = Text("")
        var currentIndex = fullText.startIndex
        
        for range in ranges {
            let beforeRange = fullText[currentIndex..<range.lowerBound]
            let highlightedRange = fullText[range]

            var foo = AttributedString(String(highlightedRange))
            foo.backgroundColor = highlightBackgroundColor
            
            highlightedText = highlightedText
                + Text(String(beforeRange))
                + Text(foo).foregroundColor(highlightColor)

            currentIndex = range.upperBound
        }
        
        highlightedText = highlightedText + Text(String(fullText[currentIndex...]))
        
        return highlightedText
    }
}

struct OIDTreeView: View {
    @ObservedObject var node: OIDNodeDisplayable
    @Binding var highlight: String

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
                            HighlightedTextView(node.getDisplayValAndSubValues(), highlight: highlight)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            HighlightedTextView(node.subnodes.last?.val ?? "", highlight: highlight)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.trailing)
                        } else {
                            HighlightedTextView(node.getDisplayValAndSubValues(), highlight: highlight)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            HighlightedTextView(node.subnodes.last?.val ?? "", highlight: highlight)
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
                        OIDTreeView(node: child, highlight: $highlight)
                    }
                }
            }) {
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.orange)
                    HighlightedTextView(node.getDisplayValAndSubValues(), highlight: highlight)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

struct ContentView: View {
   @StateObject var rootNode: OIDNodeDisplayable
    @State private var highlight: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Saisissez un filtre ici...", text: $highlight)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: highlight) { oldValue, newValue in
                        print("Texte saisi : \(newValue)")
                        rootNode.expandAll()
                        _ = rootNode.filter(newValue)
                    }
                
                Spacer(minLength: 40)
                
                Button(action: {
                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                        rootNode.expandAll()
                    }
                }, label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                })
                
                Button(action: {
                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                        rootNode.collapseAll()
                        rootNode.isExpanded = true
                    }
                }, label: {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                })
                
            }.padding(20)

            HStack {
                Button("Reload") {
                    withAnimation {
                        rootNode.children?.removeAll()
                    }
                }.border(.black)
            }
            List {
                OIDTreeView(node: rootNode, highlight: $highlight)
            }
        }
    }
}
