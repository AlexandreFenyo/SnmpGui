//
//  ContentView.swift
//  SnmpGui
//
//  Created by Alexandre Fenyo on 13/04/2025.
//

import SwiftUI

// https://developer.apple.com/documentation/swiftui/outlinegroup
// fenyo@mac ~ % snmpwalk -v2c -OT -OX -c public 192.168.0.254 > /tmp/snmpwalk.res

struct Person: Identifiable {
    let id = UUID()
    var name: String
    var phoneNumber: String
}

var staff = [
    Person(name: "Juan Chavez", phoneNumber: "(408) 555-4301"),
    Person(name: "Mei Chen", phoneNumber: "(919) 555-2481"),
]

struct FileItem: Hashable, Identifiable, CustomStringConvertible {
    var id: Self { self }
    var name: String
    var children: [FileItem]? = nil
    var description: String {
        switch children {
        case nil:
            return "📄 \(name)"
        case .some(let children):
            return children.isEmpty ? "📂 \(name)" : "📁 \(name)"
        }
    }
}


let data =
FileItem(name: "users", children:
            [FileItem(name: "user1234", children:
                        [FileItem(name: "Photos", children:
                                    [FileItem(name: "photo001.jpg"),
                                     FileItem(name: "photo002.jpg")]),
                         FileItem(name: "Movies", children:
                                    [FileItem(name: "movie001.mp4")]),
                         FileItem(name: "Documents", children: [])
                        ]),
             FileItem(name: "newuser", children:
                        [FileItem(name: "Documents", children: [])
                        ])
            ])

struct PersonRowView: View {
    var person: Person
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(person.name)
                .foregroundColor(.primary)
                .font(.headline)
            HStack(spacing: 3) {
                Label(person.phoneNumber, systemImage: "phone")
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
        }
    }
}
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            List {
                ForEach(staff) { person in
                    PersonRowView(person: person)
                }
            }

            Text("---")

            
            
            Text("---")

            OutlineGroup(data, children: \.children) { item in
                Text("\(item.description)")
            }

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
