import SwiftUI

struct SidebarView: View {
    let user: User
    @Binding var isLoggedIn: Bool // Add binding to update login status

    var body: some View {
        List {
            Section(header: Text("My Account")) {
                NavigationLink(destination: EditNameView(firstName: user.firstname, lastName: user.lastname)) {
                    VStack(alignment: .leading) {
                        Text("Name")
                        Text("\(user.firstname) \(user.lastname)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                NavigationLink(destination: EditUsernameView(username: user.pseudonym)) {
                    VStack(alignment: .leading) {
                        Text("Username")
                        Text(user.pseudonym)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                NavigationLink(destination: EditEmailView(email: user.email)) {
                    VStack(alignment: .leading) {
                        Text("Email")
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                NavigationLink(destination: EditIbanView(iban: user.iban)) {
                    VStack(alignment: .leading) {
                        Text("IBAN")
                        if user.iban.isEmpty {
                            Text("Add your IBAN")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        } else {
                            Text(user.iban)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                NavigationLink(destination: EditPasswordView()) {
                    VStack(alignment: .leading) {
                        Text("Password")
                        Text("Change your password")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }

            Section {
                Button(action: {
                    // Handle settings action
                }) {
                    Label("Settings", systemImage: "gear")
                }

                Button(action: {
                    // Handle sign out action
                    UserController.shared.signOut()
                    isLoggedIn = false // Update login status
                }) {
                    Label("Sign Out", systemImage: "arrowshape.turn.up.left")
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Menu")
    }
}
