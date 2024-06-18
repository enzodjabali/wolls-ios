import SwiftUI

struct CreateGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var groupName = ""
    @State private var groupDescription = ""
    @State private var invitedUsers: [User] = []
    @State private var filteredUsers: [User] = []
    @State private var searchPseudonym = ""
    @State private var createError: String?
    var onCreate: (Group) -> Void
    
    // Store the fetched users
    @State private var fetchedUsers: [User] = []
    @State private var usersFetched = false

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
                    TextField("Search users by username", text: $searchPseudonym)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    List(filteredUsers, id: \.id) { user in
                        Button(action: {
                            inviteUser(user)
                        }) {
                            HStack {
                                Text(user.pseudonym)
                                Spacer()
                                if invitedUsers.contains(where: { $0.id == user.id }) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
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
            .onAppear {
                if !usersFetched {
                    fetchUsers()
                    usersFetched = true
                }
            }
            .onChange(of: searchPseudonym) { _ in
                searchUsers()
            }
        }
    }

    func fetchUsers() {
        UserController.shared.fetchUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    fetchedUsers = users
                    filteredUsers = users // Initialize filteredUsers with all users
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }

    func searchUsers() {
        let searchText = searchPseudonym.lowercased()
        
        if searchText.isEmpty {
            filteredUsers = fetchedUsers // Reset to display all users
        } else {
            filteredUsers = fetchedUsers.filter { user in
                user.pseudonym.lowercased().contains(searchText)
            }
        }
    }

    func inviteUser(_ user: User) {
        if invitedUsers.contains(where: { $0.pseudonym == user.pseudonym }) {
            invitedUsers.removeAll(where: { $0.pseudonym == user.pseudonym })
        } else {
            invitedUsers.append(user)
        }
    }
    
    func createGroup() {
        // Safely unwrap UserSession.shared.userId or provide a default value
        guard let currentUserId = UserSession.shared.userId else {
            createError = "User ID not available"
            return
        }
        
        // Call GroupController to create the group
        GroupController.shared.createGroup(name: groupName, description: groupDescription, invitedUsers: invitedUsers) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(var newGroup): // Capture newGroup as mutable
                    let administrators = [currentUserId] // This assumes currentUserId is of type String

                    // Append administrators to newGroup
                    if var existingAdministrators = newGroup.administrators {
                        existingAdministrators.append(contentsOf: administrators)
                        newGroup.administrators = existingAdministrators
                    } else {
                        newGroup.administrators = administrators
                    }
                    
                    // Call onCreate with the updated newGroupFinal
                    onCreate(newGroup)
                    presentationMode.wrappedValue.dismiss()
                    
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }
}
