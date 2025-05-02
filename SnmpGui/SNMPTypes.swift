//
//  SNMPTypes.swift
//  SnmpGui
//
//  Created by Alexandre Fenyo on 23/04/2025.
//

import SwiftUI

enum OIDType {
    case root
    case mib
    case name
    case number
    case key
    case value
}

enum OIDParseError: Error {
    case invalidString
}

class OIDNodeDisplayable: Identifiable {
    var type: OIDType
    var val: String
    // OutlineGroup impose que children soit nillable
    var children: [OIDNodeDisplayable]?
    var subnodes: [OIDNodeDisplayable]
    weak var parent: OIDNodeDisplayable?

    init(type: OIDType, val: String, children: [OIDNodeDisplayable]? = nil, subnodes: [OIDNodeDisplayable] = [], parent: OIDNodeDisplayable? = nil) {
        self.type = type
        self.val = val
        self.children = children
        self.subnodes = subnodes
    }
    
    func getSingleLevelDescription() -> String {
        var description = ""
        
        switch type {
        case .root:
            description = "ROOT"
        case .mib, .name, .number:
            description = val
        case .key:
            description = "[\(val)]"
        case .value:
            description = val
        }
        
        for subnode in subnodes {
            description += "(\(subnode.getSingleLevelDescription()))"
        }
        
        return description
    }
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

    func getDisplayable() -> OIDNodeDisplayable {
        if children.isEmpty {
            return OIDNodeDisplayable(type: type, val: val)
        }
        
        let displayable_node = OIDNodeDisplayable(type: type, val: val)

        var displayable_subnodes = [OIDNodeDisplayable]()
        var current = self
        while current.children.count == 1 {
            displayable_subnodes.append(OIDNodeDisplayable(type: current.children.first!.type, val: current.children.first!.val))
            current = current.children.first!
        }

        displayable_subnodes.first?.parent = displayable_node
        if displayable_subnodes.count > 1 {
            for id in 1..<displayable_subnodes.count {
                displayable_subnodes[id].parent = displayable_subnodes[id - 1]
            }
        }
        
        var displayable_children = [OIDNodeDisplayable]()
        for child in current.children {
            let displayable_child = child.getDisplayable()
            displayable_child.parent = displayable_node
            displayable_children.append(displayable_child)
        }
        
        displayable_node.children = displayable_children
        displayable_node.subnodes = displayable_subnodes

        return displayable_node
    }
    
    func findDirectChild(type: OIDType, val: String) -> OIDNode? {
        for child in children {
            if child.type == type && child.val == val {
                return child
            }
        }
        return nil
    }

    // les deux doivent avoir la même racine
    func mergeSingleOID(_ new_oid: OIDNode) {
        if new_oid.type != type || new_oid.val != val {
            print("ERROR")
            exit(0)
        }
        
        guard let new_oid_child = new_oid.children.first else {
            return
        }
        if let tree_child = findDirectChild(type: new_oid_child.type, val: new_oid_child.val) {
            tree_child.mergeSingleOID(new_oid_child)
        } else {
            children.append(new_oid_child)
        }
    }

    static func parse(_ str: String) -> OIDNode {
        do {
            return OIDNode(type: .root, val: "", children: [try _parse(str)])
        } catch {
            print("ERROR")
            return OIDNode(type: .root, val: "")
        }
    }

    static func _parse(_ str: String) throws(OIDParseError) -> OIDNode {
        let charactersToFind: Set<Character> = [":", "[", ".", " "]

        if let idx = str.firstIndex(where: { charactersToFind.contains($0) }) {
            if str[idx] == ":" {
                let next_index = str.index(idx, offsetBy: 2)
                let next_str = str[next_index...]
                let val = str[..<idx]
                return OIDNode(type: .mib, val: String(val), children: [try _parse(String(next_str))])
            }
            if str[idx] == "[" {
                let idx_1 = str.index(after: idx)
                let key_str_to_end = str[idx_1...]
                guard let key_last_index = key_str_to_end.firstIndex(of: "]") else {
                    throw .invalidString
                }
                let key_last_index_1 = key_str_to_end.index(after: key_last_index)
                let val = key_str_to_end[..<key_last_index]
                let next_str = key_str_to_end[key_last_index_1...]
                if idx == str.startIndex {
                    return OIDNode(type: .key, val: String(val), children: [try _parse(String(next_str))])
                } else {
                    let is_number = NumberFormatter().number(from: String(str[..<idx])) != nil
                    return OIDNode(type: is_number ? .number : .name, val: String(str[..<idx]), children: [OIDNode(type: .key, val: String(val), children: [try _parse(String(next_str))])])
                }
            }
            if str[idx] == "." {
                let next_index = str.index(after: idx)
                let next_str = str[next_index...]
                let val = str[..<idx]
                let is_number = NumberFormatter().number(from: String(val)) != nil
                return OIDNode(type: is_number ? .number : .name, val: String(val), children: [try _parse(String(next_str))])
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
            
        }

        throw .invalidString
    }
    
    func dumpTree(_ level: Int = 0) {
        print("\(String.init(repeating: "-", count: level))\(type == .root ? "ROOT" : val)")
        for child in children {
            child.dumpTree(level + 1)
        }
    }
    
    func getSingleLevelDescription() -> String {
        switch type {
        case .root:
            return "ROOT"
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
