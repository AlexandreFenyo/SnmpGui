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
        // parser le fichier de valeurs snmpwalk.txt
        let filepath = Bundle.main.path(forResource: "snmpwalk", ofType: "txt")!

        print("DEBUT")

        let oid = OIDNode.parse("IP-MIB::ipAddressPrefixAutonomousFlag.2.3[4][ipv6][\"2a:01:0e:0a:02:5e:64:84:00:00:00:00:00:00:00:00\"][64] = INTEGER: true(1)")
        print("FIN")
        print("\(oid.getSingleLineDescription())")
        exit(0)
        
        if let fileHandle = FileHandle(forReadingAtPath: filepath) {
            let fileData = fileHandle.readDataToEndOfFile()
            if let fileContent = String(data: fileData, encoding: .isoLatin1) {
                fileContent.enumerateLines { line, _ in
                    
                    print(line)
                    if let mibname_end_index: Range<String.Index> = line.range(of: "::") {
                        let mibname = String(line[..<mibname_end_index.lowerBound])
                        
                        
                    }

                }
            }
            fileHandle.closeFile()
        } else {
            print("Le fichier n'existe pas à l'emplacement spécifié.")
        }
        
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
