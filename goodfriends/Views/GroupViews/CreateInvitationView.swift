import Foundation
import SwiftUI
import Combine

struct CreateInvitationView: View {
    @ObservedObject var viewModel = CreateInvitationViewModel()
    var groupId: String

    var body: some View {
        VStack {
            // Search bar to filter users
            SearchBar(text: $viewModel.searchText, placeholder: "Search users")

            // List of filtered users
            List(viewModel.filteredUsers) { user in
                HStack {
                    Text(user.pseudonym)
                    Spacer()
                    // Display checkmark if user is selected
                    if viewModel.selectedUsers.contains(user.id) {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // Toggle selection on tap
                    if viewModel.selectedUsers.contains(user.id) {
                        viewModel.selectedUsers.remove(user.id)
                    } else {
                        viewModel.selectedUsers.insert(user.id)
                    }
                }
            }
            .onAppear {
                // Fetch users when the view appears
                viewModel.fetchUsers()
            }

            // Button to send invitations
            Button(action: {
                viewModel.inviteUsers(to: groupId)
            }) {
                Text("Send Invites")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            // Show error message if applicable
            if viewModel.showError {
                Text(viewModel.errorMessage ?? "An error occurred")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationBarTitle("Invite Users")
    }
}

class CreateInvitationViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var users = [User]()
    @Published var selectedUsers = Set<String>()
    @Published var errorMessage: String?
    @Published var showError = false

    // Filtered users based on search text
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.pseudonym.lowercased().contains(searchText.lowercased()) }
        }
    }

    // Fetch users from the server
    func fetchUsers() {
        print("Fetching users...")
        UserController.shared.fetchUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.users = users
                    print("Users fetched successfully:", users)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    print("Failed to fetch users:", error)
                }
            }
        }
    }

    // Invite selected users to the specified group
    func inviteUsers(to groupId: String) {
        print("Inviting users to group with ID:", groupId)
        let selectedUsernames = users.filter { selectedUsers.contains($0.id) }.map { $0.pseudonym }
        print("Selected usernames:", selectedUsernames)
        UserController.shared.inviteUsers(to: groupId, usernames: selectedUsernames) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.selectedUsers.removeAll()
                    print("Invitations sent successfully.")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    print("Failed to send invitations:", error)
                }
            }
        }
    }
}
