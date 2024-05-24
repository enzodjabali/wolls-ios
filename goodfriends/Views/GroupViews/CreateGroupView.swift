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
                    TextField("Search users by pseudonym", text: $searchPseudonym)
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
        if let index = invitedUsers.firstIndex(where: { $0.id == user.id }) {
            invitedUsers.remove(at: index)
        } else {
            invitedUsers.append(user)
        }
    }

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
