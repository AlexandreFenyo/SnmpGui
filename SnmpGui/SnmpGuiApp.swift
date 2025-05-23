//
//  SnmpGuiApp.swift
//  SnmpGui
//
//  Created by Alexandre Fenyo on 13/04/2025.
//

import SwiftUI

@main
struct SnmpGuiApp: App {
    
    func getOIDNode() -> OIDNodeDisplayable {
        let filepath = Bundle.main.path(forResource: "snmpwalk", ofType: "txt")!

        var cnt = 0
        let oid_root: OIDNode = OIDNode(type: .root, val: "")
        if let fileHandle = FileHandle(forReadingAtPath: filepath) {
            let fileData = fileHandle.readDataToEndOfFile()
            if let fileContent = String(data: fileData, encoding: .isoLatin1) {
                fileContent.enumerateLines { line, _ in
                    print(line)
                    cnt += 1
                    oid_root.mergeSingleOID(OIDNode.parse(line))
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
        
        let oid_root_displayable = oid_root.getDisplayable()
        oid_root_displayable.val = "SNMP OID Tree"
        return oid_root_displayable
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(rootNode: getOIDNode())
        }
    }
}
