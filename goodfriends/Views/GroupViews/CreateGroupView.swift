import SwiftUI

struct CreateGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var groupName = ""
    @State private var groupDescription = ""
    @State private var invitedUsers: [User] = []
    @State private var filteredUsers: [User] = []
    @State private var searchPseudonym = ""
    @State private var createError: String?
    @State private var selectedTheme = "paris" // Default theme
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
                Section(header: Text("Theme")) {
                    Picker("Select Theme", selection: $selectedTheme) {
                        ForEach(themes, id: \.self) { theme in
                            Text(theme.localized())
                        }
                    }
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
        GroupController.shared.createGroup(name: groupName, description: groupDescription, invitedUsers: invitedUsers, theme: selectedTheme) { result in
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

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

let themes = [
    // Activities
    "biking",
    "canoeing",
    "climbing",
    "diving",
    "hiking",
    "running",
    "sauna",
    "skateboarding",
    "sunbathing",
    "swimming",
    "video-game",
    "yoga",
    // Celebrations
    "bachelor-party",
    "bachelorette-party",
    "barbecue-party",
    "christmas",
    "dia-de-muertos",
    "dj-party",
    "dragon-boat-festival",
    "halloween",
    "holi-festival",
    "house-party",
    "lohri-festival",
    "panchami-festival",
    "pongal-festival",
    "thaipusam-festival",
    "work-anniversary",
    // Cities
    "agra",
    "ahmedabad",
    "athens",
    "berlin",
    "buenos-aires",
    "dubai",
    "el-cairo",
    "hong-kong",
    "london",
    "madrid",
    "mexico",
    "moscow",
    "paris",
    "rio-de-janeiro",
    "sao-paulo",
    "sidney",
    "taipei",
    "tokyo",
    "toronto",
    // Objects
    "card-game",
    "flowers",
    "money",
    // Outdoors
    "city-skyline",
    "environment",
    "raining",
    "small-town",
    "sunrise",
    // Travel
    "airport",
    "bikini",
    "camping",
    "cruise",
    "desert",
    "exploring",
    "glamping",
    "holiday",
    "japan",
    "landscape",
    "pina-colada",
    "pool",
    "road-trip",
    "silk-road",
    "subway",
    "summer-camp",
    "tour-guide",
    "traveling",
    "vacation",
    "winter-road",
    // Work
    "coding",
    "construction-worker",
    "sailor",
    "work-meeting",
    "work",
    "working-remotely"
]
