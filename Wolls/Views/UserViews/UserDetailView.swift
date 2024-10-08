import SwiftUI

struct UserDetailView: View {
    var user: User
    var groupId: String
    @Binding var userStatuses: [UserStatus]
    @Environment(\.presentationMode) var presentationMode
    @State private var copiedIBAN = false
    @Environment(\.colorScheme) var colorScheme
    @State private var showConfirmationAlert = false
    @State private var confirmationAction: ConfirmationAction?
    @State private var createError: String?
    
    enum ConfirmationAction {
        case makeAdmin, revokeAdmin, exclude
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Spacer() // Pushes content to the top
                    
                    AvatarViewProfile(initials: userInitials(user))
                        .frame(width: 200, height: 200)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white.opacity(0.4)]), startPoint: .bottom, endPoint: .top)
                                .clipShape(Circle())
                        )
                    
                    if let firstname = user.firstname, let lastname = user.lastname {
                        Text("\(firstname) \(lastname)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    if user.id == UserSession.shared.userId {
                        Text("@" + user.pseudonym + " (me)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, -10)
                    } else {
                        Text("@" + user.pseudonym)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, -10)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        // Role Section
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Status".uppercased())
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            HStack {
                                if let isAdmin = userStatus?.is_administrator, isAdmin {
                                    Text("Administrator")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                        .padding(5)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(5)
                                } else {
                                    Text("Member")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                        .padding(5)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(5)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(boxBackgroundColor)
                            .cornerRadius(10)
                        }
                        
                        // IBAN Section
                        VStack(alignment: .leading, spacing: 5) {
                            Text("IBAN".uppercased())
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            HStack {
                                if let iban = user.iban, !iban.isEmpty {
                                    Text(iban)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                } else {
                                    Text("IBAN not provided")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                }
                                Spacer()
                                if let iban = user.iban, !iban.isEmpty {
                                    Button(action: {
                                        UIPasteboard.general.string = iban
                                        copiedIBAN = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            copiedIBAN = false
                                        }
                                    }) {
                                        Text("Copy")
                                            .foregroundColor(.blue)
                                    }
                                    .alert(isPresented: $copiedIBAN) {
                                        Alert(
                                            title: Text("IBAN Copied"),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                }
                            }
                            .padding()
                            .background(boxBackgroundColor)
                            .cornerRadius(10)
                        }
                        
                        // Balance Section
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Balance".uppercased())
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            HStack {
                                if let balance = user.balance {
                                    if balance < 0 {
                                        Rectangle()
                                            .fill(Color.red.opacity(0.8))
                                            .cornerRadius(5)
                                            .frame(width: max(CGFloat(abs(balance) / maxBalance) * maxBarWidth, 80), height: 25) // Ensure minimum width
                                            .overlay(
                                                Text("\(String(format: "%.2f", balance)) €")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                            )
                                            .padding(.horizontal, 5)
                                    } else {
                                        Rectangle()
                                            .fill(Color.green.opacity(0.8))
                                            .cornerRadius(5)
                                            .frame(width: max(CGFloat(abs(balance) / maxBalance) * maxBarWidth, 80), height: 25) // Ensure minimum width
                                            .overlay(
                                                Text("\(String(format: "%.2f", balance)) €")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                            )
                                            .padding(.horizontal, 5)
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                            .background(boxBackgroundColor)
                            .cornerRadius(10)
                        }
                    }
                    .padding([.leading, .trailing], 20)
                    
                    if isAdmin && user.id != UserSession.shared.userId {
                        VStack(spacing: 16) {
                            // Make User Administrator Button
                            if let isAdmin = userStatus?.is_administrator, isAdmin {
                                // Revoke Administrator Role Button
                                Button(action: {
                                    confirmationAction = .revokeAdmin
                                    showConfirmationAlert = true
                                }) {
                                    Text("Unset administrator")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(boxBackgroundColor)
                                        .foregroundColor(.orange)
                                        .cornerRadius(10)
                                }
                            } else {
                                Button(action: {
                                    confirmationAction = .makeAdmin
                                    showConfirmationAlert = true
                                }) {
                                    Text("Set administrator")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(boxBackgroundColor)
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                }
                            }
                            
                            // Exclude from Group Button
                            Button(action: {
                                confirmationAction = .exclude
                                showConfirmationAlert = true
                            }) {
                                Text("Exclude from Group")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(boxBackgroundColor)
                                    .foregroundColor(.red)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        .alert(isPresented: $showConfirmationAlert) {
                            Alert(
                                title: confirmationAction == .exclude ? Text("Exclude User") : Text("Change Administrator Role"),
                                message: Text(confirmationAction == .exclude ? "Are you sure you want to exclude this user from the group?" : (userStatus?.is_administrator == true ? "Are you sure you want to revoke the administrator role?" : "Are you sure you want to make this user an administrator?")),
                                primaryButton: .destructive(Text("Confirm")) {
                                    handleConfirmation()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                    
                    Spacer() // Pushes content to the top
                }
                .padding()
                .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all)) // Set the background that adapts to light/dark mode
                .navigationBarTitle("", displayMode: .inline) // Empty title to remove the default title
                .navigationBarItems(leading:
                                        Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .foregroundColor(.blue)
                }
                )
            }
        }
        .alert(isPresented: Binding<Bool>(get: { createError != nil }, set: { if !$0 { createError = nil } })) {
            Alert(title: Text("Error"), message: Text(createError ?? "An error occurred"), dismissButton: .default(Text("OK")))
        }
    }

    private func handleConfirmation() {
        guard let action = confirmationAction else { return }
        switch action {
        case .makeAdmin:
            updateAdministratorRole(isAdmin: true)
        case .revokeAdmin:
            updateAdministratorRole(isAdmin: false)
        case .exclude:
            excludeUser()
        }
    }

    private func updateAdministratorRole(isAdmin: Bool) {
        GroupMembershipController.shared.updateGroupMembership(groupId: groupId, userId: user.id, isAdmin: isAdmin) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Update the UI or perform necessary actions upon success
                    if let userIndex = userStatuses.firstIndex(where: { $0.id == user.id }) {
                        userStatuses[userIndex].is_administrator = isAdmin
                    }
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }

    private func excludeUser() {
        GroupMembershipController.shared.deleteGroupMembership(groupId: groupId, userId: user.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Handle successful exclusion and close the page
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }

    private var isAdmin: Bool {
        guard let currentUserId = UserSession.shared.userId else {
            return false
        }
        if let currentUserStatus = userStatuses.first(where: { $0.id == currentUserId }) {
            return currentUserStatus.is_administrator
        }
        return false
    }

    private func userInitials(_ user: User) -> String {
        let firstInitial = user.firstname?.first ?? "?"
        let lastInitial = user.lastname?.first ?? "?"
        return "\(firstInitial)\(lastInitial)"
    }

    private var maxBalance: Float {
        return 2000 // Replace with your logic to determine the maximum balance
    }

    private var maxBarWidth: CGFloat {
        return 200 // Replace with your desired maximum bar width
    }

    private var boxBackgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground)
    }

    private var userStatus: UserStatus? {
        userStatuses.first { $0.id == user.id }
    }
}
