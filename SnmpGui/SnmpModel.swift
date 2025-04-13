//
//  SnmpModel.swift
//  SnmpGui
//
//  Created by Alexandre Fenyo on 13/04/2025.
//

import Foundation

struct SnmpKey: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var children: [SnmpKey]? = nil

    mutating func addChild(_ child: SnmpKey) {
        if children == nil {
            children = [child]
        } else {
            children?.append(child)
        }
    }
}

@MainActor
class SnmpModel {
    static let model = SnmpModel()

    var root: SnmpKey

    init() {
        root = SnmpKey(name: ".1")
        root.addChild(SnmpKey(name: "SNMPv2-MIB::"))

        for i in 1...100 {
            var foo = SnmpKey(name: "\(i)")
            for j in 1...100 {
                var bar = SnmpKey(name: "\(i) - \(j)")
                for k in 1...100 {
                    let foobar = SnmpKey(name: "\(i) - \(j) - \(k)")
                    bar.addChild(foobar)
                }
                foo.addChild(bar)
            }
            root.addChild(foo)
        }
    }
    
    func add(_ key: SnmpKey) {
    }
}
