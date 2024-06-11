import Foundation
import SwiftUI

struct CreateInvitationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var invitedUsernames: Set<String> = []
    @State private var filteredUsers: [UserStatus] = []
    @State private var searchPseudonym = ""
    @State private var createError: String?
    @State private var userStatuses: [UserStatus] = []
    var groupId: String
    var onCreate: () -> Void
    
    @State private var members: [UserStatus] = []
    @State private var pendingMembers: [UserStatus] = []
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

    func fetchUserStatuses() {
        GroupMembershipController.shared.fetchUserStatuses(groupId: groupId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let statuses):
                    userStatuses = statuses
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

        for status in userStatuses {
            if status.hasAcceptedInvitation {
                members.append(status)
            } else if status.hasPendingInvitation {
                pendingMembers.append(status)
            } else {
                filteredUsers.append(status)
            }
        }
        searchUsers() // Update the filtered users list based on search criteria
    }

    func searchUsers() {
        let searchText = searchPseudonym.lowercased()
        
        if searchText.isEmpty {
            filteredUsers = userStatuses.filter { status in
                return !status.hasAcceptedInvitation && !status.hasPendingInvitation
            }
        } else {
            filteredUsers = userStatuses.filter { status in
                return !status.hasAcceptedInvitation && !status.hasPendingInvitation && status.pseudonym.lowercased().contains(searchText)
            }
        }
    }

    func inviteUser(_ user: UserStatus) {
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
