import SwiftUI

@main
struct WollsApp: App {
    @State private var isLoggedIn: Bool = false // Add state variable for login status

    var body: some Scene {
        WindowGroup {
            if isLoggedIn || UserDefaults.standard.string(forKey: "userToken") != nil {
                // If user is logged in or has a valid token stored locally
                GroupsView(isLoggedIn: $isLoggedIn) // Redirect to GroupsView
                    .onAppear {
                        isLoggedIn = true // Set isLoggedIn to true
                    }
            } else {
                LoginView(isLoggedIn: $isLoggedIn) // Redirect to LoginView
            }
        }
    }
}
