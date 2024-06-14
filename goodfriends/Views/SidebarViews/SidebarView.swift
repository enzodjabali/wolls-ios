import SwiftUI

struct SidebarView: View {
    let user: User
    @Binding var isLoggedIn: Bool
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
                    checkOnlyAdminGroups()
                }) {
                    Label("Delete Account", systemImage: "trash")
                        .foregroundColor(.red)
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
        
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Account"),
                message: Text("Are you sure you want to delete your account? This action is irreversible."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteUserAccount()
                },
                secondaryButton: .cancel()
            )
        }
        
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Owned Groups"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func checkOnlyAdminGroups() {
        print("Checking only admin groups")
        GroupController.shared.fetchOnlyAdminGroups { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let groups):
                    print("Owned groups fetched: \(groups)")
                    if !groups.isEmpty {
                        ownedGroups = groups
                        alertMessage = "You need to delete your groups before deleting your account:\n" + ownedGroups.map { "- \($0.name)" }.joined(separator: "\n")
                        print("Alert message: \(alertMessage)") // Debug statement
                        showAlert = true
                        print("Show alert: \(showAlert)") // Debug statement
                    } else {
                        showDeleteConfirmation = true
                        print("Show delete confirmation: \(showDeleteConfirmation)") // Debug statement
                    }
                case .failure(let error):
                    print("Error fetching owned groups: \(error.localizedDescription)")
                    alertMessage = "Error fetching owned groups: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }

    private func deleteUserAccount() {
        print("Deleting user account")
        UserController.shared.deleteAccount { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Account deleted successfully")
                    isLoggedIn = false // Update login status
                case .failure(let error):
                    print("Error deleting account: \(error.localizedDescription)")
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}
