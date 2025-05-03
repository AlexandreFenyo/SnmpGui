
import SwiftUI

class TreeNode: Identifiable, ObservableObject {
    @Published var name: String = ""
    @Published var children: [TreeNode]? = nil
    @Published var isExpanded: Bool = true

    init(name: String, children: [TreeNode]? = nil, isExpanded: Bool = true) {
        self.name = name
        self.children = children
        self.isExpanded = isExpanded
    }
}

struct TreeView: View {
    @ObservedObject var node: TreeNode

    var body: some View {
        if node.children == nil || node.children?.isEmpty == true {
            Text(node.name).padding(.leading, 20)
        }
        else {
            DisclosureGroup(node.name, isExpanded: $node.isExpanded) {
                if let children = node.children {
                    ForEach(children) { child in
                        TreeView(node: child)
                    }
                }
            }
            .padding(.leading, 20)
        }
    }
}

/*
struct ContentView: View {
    @StateObject var rootNode: TreeNode

    var body: some View {
        Button("Reload") {
            rootNode.children?.removeAll()
        }
        NavigationView {
            List {
                TreeView(node: rootNode)
            }
            .navigationTitle("Arbre")
        }
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(rootNode: exampleTree())
        }
    }

    func exampleTree() -> TreeNode {
        let child1 = TreeNode(name: "Child 1", children: nil)
        let child2 = TreeNode(name: "Child 2")
        let child3 = TreeNode(name: "Child 3", children: [child1, child2])
        let root = TreeNode(name: "Root", children: [child3])
        return root
    }
}
*/
