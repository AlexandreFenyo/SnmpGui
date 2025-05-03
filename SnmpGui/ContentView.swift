//
//  ContentView.swift
//  SnmpGui
//
//  Created by Alexandre Fenyo on 13/04/2025.
//

import SwiftUI

// https://developer.apple.com/documentation/swiftui/outlinegroup
// fenyo@mac ~ % snmpwalk -v2c -OT -OX -c public 192.168.0.254 > /tmp/snmpwalk.res

struct XContentView: View {
    @State private var text: String = ""
    
    var body: some View {
        VStack {
            Button {
//                SnmpModel.model.oid_root_displayable = OIDNodeDisplayable(type: .root, val: "")
                SnmpModel.model.oid_root_displayable.children?.first?.val = "ddx"
//                SnmpModel.model.oid_root.getDisplayable()
            } label: {
                Text("Collapse everything")
            }
            
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
                            VStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.blue)
                                    .padding(.trailing, 5)
                            }
                            VStack {
                                HStack(alignment: .top) {
                                    Text(item.getDisplayValAndSubValues())
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(item.subnodes.last?.val ?? "ERREUR").font(.subheadline)
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                        .onTapGesture {
                            print(item.line)
                        }
                    }
                }
            }
        }
    }
}
