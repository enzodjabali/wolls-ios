import SwiftUI

struct CreateInvitationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var invitedUsernames: Set<String> = []
    @State private var filteredUsers: [UserStatus] = []
    @State private var searchPseudonym = ""
    @State private var createError: String?
    @State private var userStatuses: [UserStatus] = []
    @State private var showSuccessAlert = false
    @State private var pendingUser: UserStatus?
    @State private var showUserDetail = false
    @State private var selectedUserId: String?
    @State private var selectedUser: User?
    
    var groupId: String
    var onCreate: () -> Void
    var administrators: [String]
    var isAdmin: Bool

    @State private var members: [UserStatus] = []
    @State private var pendingMembers: [UserStatus] = []
    @State private var usersFetched = false

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Members")) {
                    List(members, id: \.id) { user in
                        Button(action: {
                            selectedUserId = user.id
                            showUserDetail = true
                            fetchUserDetails(userId: user.id)
                        }) {
                            HStack {
                                Text(user.pseudonym)
                                if user.id == UserSession.shared.userId {
                                    Text("(me)")
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                if administrators.contains(user.id) {
                                    Image(systemName: "person.badge.key")
                                } else {
                                    Image(systemName: "person")
                                }
                            }
                        }
                    }
                }
                
                if pendingMembers.count > 0 {
                    Section(header: Text("Pending Invitations")) {
                        List(pendingMembers, id: \.id) { user in
                            Button(action: {
                                pendingUser = user
                            }) {
                                HStack {
                                    Text(user.pseudonym)
                                    Spacer()
                                    Text("Pending")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .alert(isPresented: Binding<Bool>(
                            get: { pendingUser != nil },
                            set: { if !$0 { pendingUser = nil } }
                        )) {
                            Alert(
                                title: Text("Pending Invitation"),
                                message: Text("\(pendingUser?.pseudonym ?? "This user") has a pending invitation. Wait for them to accept it to start sharing expenses."),
                                dismissButton: .default(Text("OK")) {
                                    pendingUser = nil
                                }
                            )
                        }
                    }
                }
                
                if isAdmin {
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
            }
            .navigationTitle("Users")
            .onAppear {
                if !usersFetched {
                    fetchUserStatuses()
                    usersFetched = true
                }
            }
            
            if isAdmin && !invitedUsernames.isEmpty {
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
            }
            
            if let error = createError {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Invitations Sent"),
                message: Text("The invitations have been successfully sent."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showUserDetail) {
            if let selectedUser = selectedUser {
                UserDetailView(user: selectedUser)
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
        filteredUsers = []

        for status in userStatuses {
            if status.hasAcceptedInvitation {
                members.append(status)
            } else if status.hasPendingInvitation {
                pendingMembers.append(status)
            } else {
                filteredUsers.append(status)
            }
        }
        searchUsers()
    }

    func searchUsers() {
        if searchPseudonym.isEmpty {
            filteredUsers = userStatuses.filter { status in
                !status.hasAcceptedInvitation && !status.hasPendingInvitation
            }
        } else {
            filteredUsers = userStatuses.filter { status in
                !status.hasAcceptedInvitation && !status.hasPendingInvitation && status.pseudonym.lowercased().contains(searchPseudonym.lowercased())
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
                    showSuccessAlert = true
                    onCreate()
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }

    private func fetchUserDetails(userId: String) {
        UserController.shared.fetchUserDetails(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.selectedUser = user
                case .failure(let error):
                    self.createError = error.localizedDescription
                }
            }
        }
    }
}
