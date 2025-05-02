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
            ScrollView {
                OutlineGroup(SnmpModel.model.oid_root_displayable, children: \.children) { item in
                    VStack {

                        Text(item.val == "" ? "ROOT" : item.val)

                        ForEach(item.subnodes) { subnode in
                            Text(subnode.getSingleLevelDescription())
                        }
                    }.border(Color.gray)
                }
            }.font(.system(size: 10))

        }
        .padding()
    }
}
