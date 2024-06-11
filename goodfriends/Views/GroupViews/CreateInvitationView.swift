import Foundation
import SwiftUI
import Combine

struct CreateInvitationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var invitedUsernames: Set<String> = []
    @State private var filteredUsers: [User] = []
    @State private var searchPseudonym = ""
    @State private var createError: String?
    @State private var userStatuses: [String: UserStatus] = [:]
    var groupId: String
    var onCreate: () -> Void
    
    @State private var fetchedUsers: [User] = []
    @State private var members: [User] = []
    @State private var pendingMembers: [User] = []
    @State private var usersFetched = false

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Members")) {
                    List(members, id: \.id) { user in
                        Button(action: {
                            // Navigate to member details
                        }) {
                            HStack {
                                Text(user.pseudonym)
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                        .background(
                            NavigationLink("", destination: Text("Hello World"))
                                .opacity(0)
                        )
                    }
                }

                Section(header: Text("Pending Invitations")) {
                    List(pendingMembers, id: \.id) { user in
                        HStack {
                            Text(user.pseudonym)
                            Spacer()
                            Text("Pending")
                                .foregroundColor(.orange)
                        }
                    }
                }

                Section(header: Text("Invite Users")) {
                    TextField("Search users by username", text: $searchPseudonym)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: searchPseudonym) { _ in
                            searchUsers()
                        }
                    
                    List(filteredUsers, id: \.id) { user in
                        Button(action: {
                            inviteUser(user)
                        }) {
                            HStack {
                                Text(user.pseudonym)
                                Spacer()
                                if invitedUsernames.contains(user.pseudonym) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Invite users")
            .onAppear {
                if !usersFetched {
                    fetchUsers()
                    fetchUserStatuses()
                    usersFetched = true
                }
            }
            
            Button(action: {
                sendInvitations()
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
            
            if let error = createError {
                Text(error)
                    .foregroundColor(.red)
            }
        }
    }

    func fetchUsers() {
        UserController.shared.fetchUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    fetchedUsers = users
                    fetchUserStatuses() // Fetch statuses after users are fetched
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }
    
    func fetchUserStatuses() {
        GroupMembershipController.shared.fetchUserStatuses(groupId: groupId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let statuses):
                    userStatuses = Dictionary(uniqueKeysWithValues: statuses.map { ($0.pseudonym, $0) })
                    categorizeUsers()
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }

    func categorizeUsers() {
        members = []
        pendingMembers = []
        filteredUsers = [] // Reset filtered users

        for user in fetchedUsers {
            if let status = userStatuses[user.pseudonym] {
                if status.hasAcceptedInvitation {
                    members.append(user)
                } else if status.hasPendingInvitation {
                    pendingMembers.append(user)
                } else {
                    filteredUsers.append(user) // Add to filtered users if not a member or pending
                }
            } else {
                filteredUsers.append(user) // Add to filtered users if no status
            }
        }
        searchUsers() // Update the filtered users list based on search criteria
    }

    func searchUsers() {
        let searchText = searchPseudonym.lowercased()
        
        if searchText.isEmpty {
            filteredUsers = fetchedUsers.filter { user in
                guard let status = userStatuses[user.pseudonym] else { return true }
                return !status.hasAcceptedInvitation && !status.hasPendingInvitation
            }
        } else {
            filteredUsers = fetchedUsers.filter { user in
                guard let status = userStatuses[user.pseudonym] else { return false }
                return !status.hasAcceptedInvitation && !status.hasPendingInvitation && user.pseudonym.lowercased().contains(searchText)
            }
        }
    }

    func inviteUser(_ user: User) {
        if invitedUsernames.contains(user.pseudonym) {
            invitedUsernames.remove(user.pseudonym)
        } else {
            invitedUsernames.insert(user.pseudonym)
        }
    }

    func sendInvitations() {
        let usernames = Array(invitedUsernames)
        GroupMembershipController.shared.inviteUsers(to: groupId, usernames: usernames) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    onCreate()
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }
}
