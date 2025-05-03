//
//  SnmpModel.swift
//  SnmpGui
//
//  Created by Alexandre Fenyo on 13/04/2025.
//

import Foundation

@MainActor
class SnmpModel {
    static let model = SnmpModel()

    var oid_root: OIDNode = OIDNode(type: .root, val: "")
    /*@Published*/ var oid_root_displayable: OIDNodeDisplayable = OIDNodeDisplayable(type: .root, val: "")

    init() {
/*
        // parser le fichier de valeurs snmpwalk.txt
        let filepath = Bundle.main.path(forResource: "snmpwalk", ofType: "txt")!

        var cnt = 0
        oid_root = OIDNode(type: .root, val: "")
        if let fileHandle = FileHandle(forReadingAtPath: filepath) {
            let fileData = fileHandle.readDataToEndOfFile()
            if let fileContent = String(data: fileData, encoding: .isoLatin1) {
                fileContent.enumerateLines { line, _ in
                    print(line)
                    cnt += 1
                    self.oid_root.mergeSingleOID(OIDNode.parse(line))
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
        
        oid_root_displayable = oid_root.getDisplayable()
        oid_root_displayable.val = "SNMP OID Tree"
        */
    }
}
