import SwiftUI

@main
struct GoodfriendsApp: App {
    @State private var isLoggedIn: Bool = false // Add state variable for login status

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                GroupsView(isLoggedIn: $isLoggedIn) // Pass isLoggedIn to GroupsView
            } else {
                LoginView(isLoggedIn: $isLoggedIn) // Pass isLoggedIn to LoginView
            }
        }
    }
}
