import SwiftUI

struct SidebarView: View {
    let user: User
    @Binding var isLoggedIn: Bool
    @State private var alertMessageTitle = ""
    @State private var alertMessage = ""
    @State private var showGroupsListOnlyAdmin = false
    @State private var showDeleteConfirmation = false
    @State private var onlyAdminGroups: [Group] = []
    @State private var activeAlert: ActiveAlert?

    enum ActiveAlert: Identifiable {
        case groupsListOnlyAdmin
        case deleteConfirmation
        
        var id: Int {
            hashValue
        }
    }
    
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
                
                NavigationLink(destination: EditUsernameView(username: user.pseudonym)) {
                    VStack(alignment: .leading) {
                        Text("Username")
                        Text(user.pseudonym)
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
                                .foregroundColor(.orange)
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
            
            Section(header: Text("Settings")) {
                Button(action: {
                    openAppSettings()
                }) {
                    Text("Language")
                }
            }
            
            Section {
                Button(action: {
                    // Handle sign out action
                    UserController.shared.signOut()
                    isLoggedIn = false // Update login status
                }) {
                    Text("Sign Out")
                }
                
                Button(action: {
                    checkOnlyAdminGroups()
                }) {
                    Text("Delete Account")
                        .foregroundColor(.red)
                }
            }
            .alert(item: $activeAlert) { alert in
                switch alert {
                case .groupsListOnlyAdmin:
                    return Alert(
                        title: Text(alertMessageTitle),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                case .deleteConfirmation:
                    return Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete your account? This will permanently erase your account."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteUserAccount()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            
            Section {
                VStack {
                    Text("Wolls v" + AppInfo.version)
                    Text("Made in France")
                }
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 10)
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Menu")
    }
    
    private func checkOnlyAdminGroups() {
        GroupController.shared.fetchOnlyAdminGroups { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let groups):
                    if !groups.isEmpty {
                        onlyAdminGroups = groups
                        alertMessageTitle = "Hold on!"
                        alertMessage = "You are the only administrator of the following groups:\n" + onlyAdminGroups.map { "- \($0.name)" }.joined(separator: "\n") + " \n\nYou need to delete them or make another user administrator before deleting your account."
                        activeAlert = .groupsListOnlyAdmin
                    } else {
                        activeAlert = .deleteConfirmation
                    }
                case .failure(let error):
                    showAlert(title: "Error", message: "Error fetching the groups: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func deleteUserAccount() {
        UserController.shared.deleteAccount { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    UserController.shared.signOut()
                    isLoggedIn = false // Update login status after successful deletion
                case .failure(let error):
                    showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertMessageTitle = title
        alertMessage = message
        activeAlert = .groupsListOnlyAdmin
    }
    
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true if Settings opened successfully
            })
        }
    }
}
