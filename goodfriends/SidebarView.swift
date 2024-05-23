import SwiftUI

struct SidebarView: View {
    var body: some View {
        List {
            // Edit Personal Info
            Button(action: {
                // Handle action for editing personal info
            }) {
                Label("marcopolo", systemImage: "person.crop.circle")
            }

            // Settings
            Button(action: {
                // Handle action for settings
            }) {
                Label("Settings", systemImage: "gear")
            }

            // Sign Out
            Button(action: {
                // Handle action for signing out
            }) {
                Label("Sign Out", systemImage: "arrowshape.turn.up.left")
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
        .navigationTitle("Hi")
    }
}
