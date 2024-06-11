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
    @State private var usersFetched = false

    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Search users by username", text: $searchPseudonym)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    List(filteredUsers, id: \.id) { user in
                        let status = userStatuses[user.pseudonym]
                        let isDisabled = status?.hasAcceptedInvitation == true || status?.hasPendingInvitation == true
                        
                        Button(action: {
                            if !isDisabled {
                                inviteUser(user)
                            }
                        }) {
                            HStack {
                                Text(user.pseudonym)
                                Spacer()
                                if let status = status {
                                    if status.hasAcceptedInvitation {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                        Text("Member")
                                            .foregroundColor(.green)
                                    } else if status.hasPendingInvitation {
                                        Text("Pending")
                                            .foregroundColor(.orange)
                                    } else if invitedUsernames.contains(user.pseudonym) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        .disabled(isDisabled)
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
            .onChange(of: searchPseudonym) { _ in
                searchUsers()
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
                    filteredUsers = users
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
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }

    func searchUsers() {
        let searchText = searchPseudonym.lowercased()
        
        if searchText.isEmpty {
            filteredUsers = fetchedUsers
        } else {
            filteredUsers = fetchedUsers.filter { user in
                user.pseudonym.lowercased().contains(searchText)
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
