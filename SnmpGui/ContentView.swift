//
//  ContentView.swift
//  SnmpGui
//
//  Created by Alexandre Fenyo on 13/04/2025.
//

import SwiftUI

// https://developer.apple.com/documentation/swiftui/outlinegroup
// fenyo@mac ~ % snmpwalk -v2c -OT -OX -c public 192.168.0.254 > /tmp/snmpwalk.res

struct ContentView: View {
    var body: some View {
        VStack {
            List {
                OutlineGroup(SnmpModel.model.oid_root_displayable, children: \.children) { item in
                    if let _ = item.children {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.orange)
                            Text(item.getDisplayValAndSubValues())
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    } else {
                        // No children
                        HStack(alignment: .top) {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                                .padding(.trailing, 5)
                            HStack(alignment: .top) {
                                HStack(alignment: .top) {
                                    Text(item.getDisplayValAndSubValues())
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    Text(item.subnodes.last?.val ?? "ERREUR").font(.subheadline)
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            
                        }
                        
                            }
                    
                }
            }//.font(.system(size: 10))
            
        }
    }
}
