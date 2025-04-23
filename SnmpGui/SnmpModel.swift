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
    var oid_root: OIDNode
    var oid_root2: OIDNode2 = OIDNode2(type: .root, val: "")

    init() {
        // parser le fichier de valeurs snmpwalk.txt
        let filepath = Bundle.main.path(forResource: "snmpwalk", ofType: "txt")!

        var cnt = 0
        let oid = OIDNode(type: .root, val: "")
        if let fileHandle = FileHandle(forReadingAtPath: filepath) {
            let fileData = fileHandle.readDataToEndOfFile()
            if let fileContent = String(data: fileData, encoding: .isoLatin1) {
                fileContent.enumerateLines { line, _ in
                    print(line)
                    cnt += 1
                    oid.mergeSingleOID(OIDNode.parse(line))
                    /*
                    if cnt == 1200 /* pb à 907 */ {
                        print("FIN")
                        oid.dumpTree()
                        exit(0)
                    }*/
                }
            }
            fileHandle.closeFile()
        } else {
            print("Le fichier n'existe pas à l'emplacement spécifié.")
        }
        oid_root = oid

        
        cnt = 0
        let oid2 = OIDNode2(type: .root, val: "")
        if let fileHandle = FileHandle(forReadingAtPath: filepath) {
            let fileData = fileHandle.readDataToEndOfFile()
            if let fileContent = String(data: fileData, encoding: .isoLatin1) {
                fileContent.enumerateLines { line, _ in
                    print(line)
                    cnt += 1
                    oid2.mergeSingleOID(OIDNode2.parse(line))
                    /*
                    if cnt == 1200 /* pb à 907 */ {
                        print("FIN")
                        oid.dumpTree()
                        exit(0)
                    }*/
                }
            }
            fileHandle.closeFile()
        } else {
            print("Le fichier n'existe pas à l'emplacement spécifié.")
        }
        oid_root2 = oid2

        
        
        
        
        
        
        
        
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
