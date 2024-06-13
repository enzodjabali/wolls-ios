import SwiftUI

struct SidebarView: View {
    let user: User
    @Binding var isLoggedIn: Bool // Add binding to update login status
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteConfirmation = false
    @State private var ownedGroups: [Group] = []

    var body: some View {
        List {
            Section(header: Text("My Account")) {
                NavigationLink(destination: EditNameView(firstName: user.firstname ?? "", lastName: user.lastname ?? "")) {
                    VStack(alignment: .leading) {
                        Text("Name")
                        Text("\(user.firstname ?? "") \(user.lastname ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                NavigationLink(destination: EditUsernameView(username: user.pseudonym ?? "")) {
                    VStack(alignment: .leading) {
                        Text("Username")
                        Text(user.pseudonym ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                NavigationLink(destination: EditEmailView(email: user.email ?? "")) {
                    VStack(alignment: .leading) {
                        Text("Email")
                        Text(user.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                NavigationLink(destination: EditIbanView(iban: user.iban ?? "")) {
                    VStack(alignment: .leading) {
                        Text("IBAN")
                        if let iban = user.iban, !iban.isEmpty {
                            Text(iban)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            Text("Add your IBAN")
                                .font(.subheadline)
                                .foregroundColor(.red)
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
                    deleteUserAccount()
                }) {
                    Label("Delete Account", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .alert(isPresented: $showAlert) {
                    if !ownedGroups.isEmpty {
                        return Alert(
                            title: Text("Cannot Delete Account"),
                            message: Text("You need to delete your groups before deleting your account:\n" + ownedGroups.map { "- \($0.name)" }.joined(separator: "\n")),
                            dismissButton: .default(Text("OK"))
                        )
                    } else {
                        return Alert(
                            title: Text("Delete Account"),
                            message: Text("Are you sure you want to delete your account? This action is irreversible."),
                            primaryButton: .destructive(Text("Delete")) {
                                deleteUserAccount()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }

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
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func deleteUserAccount() {
        UserController.shared.deleteAccount { result in
            switch result {
            case .success:
                isLoggedIn = false // Update login status
            case .failure(let error):
                switch error {
                case .ownsGroups(let groups):
                    ownedGroups = groups
                    showAlert = true
                default:
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}
