import SwiftUI

struct CreateGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var groupName = ""
    @State private var groupDescription = ""
    @State private var invitedUsers: [User] = [] // Track invited users
    @State private var suggestedUsers: [User] = [] // Track suggested users
    @State private var searchPseudonym = "" // Track user search
    @State private var createError: String?
    var onCreate: (Group) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Name")) {
                    TextField("Enter group name", text: $groupName)
                }
                Section(header: Text("Description")) {
                    TextField("Enter description", text: $groupDescription)
                }
                Section(header: Text("Invite Users")) {
                    // Text field to search and invite users
                    TextField("Search users by pseudonym", text: $searchPseudonym)
                        .onChange(of: searchPseudonym) { _ in
                            searchUsers()
                        }
                    
                    // List to display suggested users
                    List(suggestedUsers) { user in
                        Button(action: {
                            inviteUser(user)
                        }) {
                            Text(user.pseudonym)
                        }
                    }
                }
                if let error = createError {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Create a group")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Create") {
                createGroup()
            })
        }
        .onAppear {
            fetchUsers() // Fetch users when view appears
        }
    }

    // Fetch users from the server
    func fetchUsers() {
        UserController.shared.fetchUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    suggestedUsers = users // Populate suggested users
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }

    // Search users based on pseudonym
    func searchUsers() {
        // Filter suggested users based on search pseudonym
        suggestedUsers = UserController.shared.users.filter {
            $0.pseudonym.lowercased().contains(searchPseudonym.lowercased())
        }
    }

    // Invite user to the group
    func inviteUser(_ user: User) {
        invitedUsers.append(user) // Add user to invited users
        // Optionally, remove user from suggested users after invitation
        // suggestedUsers.removeAll(where: { $0.id == user.id })
    }

    // Create a new group
    func createGroup() {
        GroupController.shared.createGroup(name: groupName, description: groupDescription, invitedUsers: invitedUsers) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newGroup):
                    onCreate(newGroup)
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }
}
