import SwiftUI

struct SidebarView: View {
    var body: some View {
        List {
            Text("Sidebar Item 1")
            Text("Sidebar Item 2")
            Text("Sidebar Item 3")
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
        .navigationTitle("Sidebar")
    }
}
