import Foundation
import SwiftUI
import Combine

struct CreateInvitationView: View {
    @ObservedObject var viewModel = CreateInvitationViewModel()
    var groupId: String

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.searchText, placeholder: "Search users")

            List(viewModel.filteredUsers) { user in
                HStack {
                    Text(user.pseudonym)
                    Spacer()
                    if viewModel.selectedUsers.contains(user.id) {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.selectedUsers.contains(user.id) {
                        viewModel.selectedUsers.remove(user.id)
                    } else {
                        viewModel.selectedUsers.insert(user.id)
                    }
                }
            }
            .onAppear {
                viewModel.fetchUsers()
            }

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

    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.pseudonym.lowercased().contains(searchText.lowercased()) }
        }
    }

    func fetchUsers() {
        UserController.shared.fetchUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.users = users
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }

    func inviteUsers(to groupId: String) {
        let userIds = Array(selectedUsers)
        UserController.shared.inviteUsers(to: groupId, userIds: userIds) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.selectedUsers.removeAll()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
}
