//
//  SnmpGuiApp.swift
//  SnmpGui
//
//  Created by Alexandre Fenyo on 13/04/2025.
//

import SwiftUI

@main
struct SnmpGuiApp: App {
    
    init() {
        let foo = SnmpKey(name: ".1")
        SnmpModel.model.add(foo)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
