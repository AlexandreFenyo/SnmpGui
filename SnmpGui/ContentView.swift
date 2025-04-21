//
//  ContentView.swift
//  SnmpGui
//
//  Created by Alexandre Fenyo on 13/04/2025.
//

import SwiftUI

// https://developer.apple.com/documentation/swiftui/outlinegroup
// fenyo@mac ~ % snmpwalk -v2c -OT -OX -c public 192.168.0.254 > /tmp/snmpwalk.res

enum OIDType {
    case root
    case mib
    case name
    case number
    case key
    case value
}

class OIDNode {
    let type: OIDType
    let val: String
    var children: [OIDNode]
    
    init(type: OIDType, val: String, children: [OIDNode] = []) {
        self.type = type
        self.val = val
        self.children = children
    }
    
    static func parse(_ str: String) -> OIDNode {

        let charactersToFind: Set<Character> = [":", "[", ".", " "]

        if let idx = str.firstIndex(where: { charactersToFind.contains($0) }) {
            if str[idx] == ":" {
                let next_index = str.index(idx, offsetBy: 2)
                let next_str = str[next_index...]
                let val = str[..<idx]
                return OIDNode(type: .mib, val: String(val), children: [parse(String(next_str))])
            }
            if str[idx] == "[" {
                let idx_1 = str.index(after: idx)
                let key_str_to_end = str[idx_1...]
                guard let key_last_index = key_str_to_end.firstIndex(of: "]") else {
                    return OIDNode(type: .number, val: "parse snmp SHOULD NOT BE HERE 1")
                }
                let key_last_index_1 = key_str_to_end.index(after: key_last_index)
                let val = key_str_to_end[..<key_last_index]
                let next_str = key_str_to_end[key_last_index_1...]
                if idx == str.startIndex {
                    return OIDNode(type: .key, val: String(val), children: [parse(String(next_str))])
                } else {
                    let is_number = NumberFormatter().number(from: String(str[..<idx])) != nil
                    return OIDNode(type: is_number ? .number : .name, val: String(str[..<idx]), children: [OIDNode(type: .key, val: String(val), children: [parse(String(next_str))])])
                }
            }
            if str[idx] == "." {
                let next_index = str.index(after: idx)
                let next_str = str[next_index...]
                let val = str[..<idx]
                let is_number = NumberFormatter().number(from: String(val)) != nil
                return OIDNode(type: is_number ? .number : .name, val: String(val), children: [parse(String(next_str))])
            }
            if str[idx] == " " {
                let next_index = str.index(idx, offsetBy: 3)
                let next_str = str[next_index...]
                let val = next_str
                if idx == str.startIndex {
                    return OIDNode(type: .value, val: String(val))
                } else {
                    let is_number = NumberFormatter().number(from: String(str[..<idx])) != nil
                    return OIDNode(type: is_number ? .number : .name, val: String(str[..<idx]), children: [OIDNode(type: .value, val: String(val))])
                }
            }
            
        } else {
            print("Aucun des caractères spécifiés n'a été trouvé dans la chaîne.")
        }

        return OIDNode(type: .number, val: "parse snmp SHOULD NOT BE HERE 1")
    }
    
    func getSingleLevelDescription() -> String {
        switch type {
        case .root:
            return ""
        case .mib, .name, .number:
            return val
        case .key:
            return "[\(val)]"
        case .value:
            return val
        }
    }

    func getSingleLineDescription() -> String {
        switch type {
        case .root:
            return children.first?.getSingleLineDescription() ?? ""
        case .mib:
            return "\(val)::\(children.first?.getSingleLineDescription() ?? "")"
        case .name, .number:
            if children.first?.type == .name || children.first?.type == .number {
                return "\(val).\(children.first?.getSingleLineDescription() ?? "")"
            } else {
                return "\(val)\(children.first?.getSingleLineDescription() ?? "")"
            }
        case .key:
            return "[\(val)]\(children.first?.getSingleLineDescription() ?? "")"
        case .value:
            return " = \(val)"
        }
    }
}

struct FileItem: Hashable, Identifiable, CustomStringConvertible {
    var id: Self { self }
    var name: String
    var children: [FileItem]? = nil
    var description: String {
        switch children {
        case nil:
            return "📄 \(name)"
        case .some(let children):
            return children.isEmpty ? "     \(name)" : "📁 \(name)"
        }
    }
}

let data =
FileItem(name: "users", children:
            [FileItem(name: "usezefoi jzefo ijzef ojizef ozeifj iozef jozef izeojr1234", children:
                        [FileItem(name: "Phzefio jzeoi fjezjfo ij foeizfj ootos", children:
                                    [FileItem(name: "photo001.jpg"),
                                     FileItem(name: "photo002.jpg")]),
                         FileItem(name: "Movies", children:
                                    [FileItem(name: "movie001.mp4")]),
                         FileItem(name: "Documents", children: [])
                        ]),
             FileItem(name: "IF-MIB::ifOperStatus", children:
                        [FileItem(name: "IF-MIB::ifOperStatus[10103]", children: []),
                         FileItem(name: "IF-MIB::ifOperStatus[10104]", children: []),
                         FileItem(name: "IP-MIB::ipNetToPhysicalLastUpdated[4][ipv6][\"2a:01:0e:0a:02:5e:64:84:25:1b:5b:13:69:c0:2a:02\"]", children: []),
                         FileItem(name: "IP-MIB::ipNetToPhysicalLastUpdated", children: [
                            FileItem(name: "    [5][ipv6][\"2a:01:0e:0a:02:5e:64:84:25:1b:5b:13:69:c0:2a:02\"]", children: [])
                         ]),
                        ])
            ])

struct ContentView: View {
    var body: some View {
        VStack {
            ScrollView {
                OutlineGroup(SnmpModel.model.root, children: \.children) { item in
                    Text("\(item.name)")
                }
            }
            
            Text("---")

            OutlineGroup(data, children: \.children) { item in
                Text("\(item.description)").font(.system(size: 8))
            }

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
