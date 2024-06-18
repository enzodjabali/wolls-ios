import SwiftUI

class UserSession {
    static let shared = UserSession()
    var userId: String? // Variable to store the user ID

    private init() {} // Private initializer to prevent multiple instances
}

struct GroupsView: View {
    @State private var groups: [Group] = []
    @State private var fetchError: String?
    @State private var isLoading: Bool = true
    @State private var showCreateGroupSheet = false
    @State private var currentUser: User?
    @State private var currentUserInitials = ""
    @State private var isSidebarOpen = false
    @State private var invitationCount: Int = 0
    @State private var showAlert = false
    @State private var selectedGroup: Group?
    @State private var actionType: ActionType = .none
    @Binding var isLoggedIn: Bool

    enum ActionType {
        case none
        case delete
        case leave
    }

    init(isLoggedIn: Binding<Bool>) {
        _isLoggedIn = isLoggedIn
    }

    var body: some View {
        if isLoggedIn {
            NavigationView {
                ZStack(alignment: .leading) {
                    // Main content
                    VStack {
                        if isLoading {
                            ProgressView("Loading...")
                                .padding()
                        } else if let error = fetchError {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            if groups.isEmpty {
                                VStack {
                                    Image("nothing")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 250, height: 250)
                                        .foregroundColor(.gray)

                                    Text("You don't have any groups yet.")
                                        .foregroundColor(.gray)

                                    Button(action: {
                                        showCreateGroupSheet.toggle()
                                    }) {
                                        Text("Create Your First Group")
                                            .foregroundColor(.blue)
                                            .padding()
                                    }
                                }
                            } else {
                                List {
                                    ForEach(groups) { group in
                                        NavigationLink(destination: GroupDetailsView(groupId: group.id, groupName: group.name, groupDescription: group.description ?? "", groupCreatedAt: group.createdAt ?? "", administrators: group.administrators ?? [], isLoggedIn: $isLoggedIn)) {
                                            GroupBoxView(group: group)
                                        }
                                        .swipeActions {
                                            Button {
                                                self.selectedGroup = group
                                                self.actionType = isAdmin(of: group) ? .delete : .leave
                                                self.showAlert = true
                                            } label: {
                                                Text(isAdmin(of: group) ? "Delete" : "Leave")
                                            }
                                            .tint(isAdmin(of: group) ? .red : .blue)
                                        }
                                    }
                                    .listRowSeparator(.hidden)
                                }
                                .listStyle(PlainListStyle())
                                .transition(.opacity)
                                .refreshable {
                                    // Code to run when the list is pulled down to refresh
                                    fetchCurrentUser()
                                    fetchGroups()
                                    fetchInvitationCount()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Overlay to close sidebar
                    Color.clear
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                isSidebarOpen.toggle()
                            }
                        }
                        .zIndex(1) // Ensure the overlay is above the main content

                    // Dark overlay
                    if isSidebarOpen {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                            .zIndex(2)
                    }

                    // Sidebar
                    if isSidebarOpen, let currentUser = currentUser {
                        SidebarView(user: currentUser, isLoggedIn: $isLoggedIn)
                            .frame(width: 300)
                            .transition(.move(edge: .leading))
                            .zIndex(3)
                    }
                }
                .onAppear {
                    fetchCurrentUser()
                    fetchGroups()
                    fetchInvitationCount()
                }
                .navigationTitle("Groups")
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(
                    leading: HStack {
                        // Avatar view
                        AvatarView(initials: currentUserInitials)
                            .onTapGesture {
                                withAnimation {
                                    isSidebarOpen.toggle()
                                }
                            }
                            .frame(width: 35, height: 35)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white.opacity(0.4)]), startPoint: .bottom, endPoint: .top)
                                    .clipShape(Circle())
                            )
                    },
                    trailing: HStack {
                        // Button to open the page with waiting invitations
                        ZStack {
                            NavigationLink(destination: InvitationsView()) {
                                Image(systemName: "envelope")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle()) // Remove the default button style
                            .opacity(isSidebarOpen ? 0 : 1) // Hide when sidebar is open

                            // Badge
                            if invitationCount > 0 {
                                Text("\(invitationCount)")
                                    .font(.caption2)
                                    .padding(5)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .foregroundColor(.white)
                                    .offset(x: 13, y: -10)
                                    .opacity(isSidebarOpen ? 0 : 1) // Hide when sidebar is open
                            }
                        }
                        
                        // Plus button
                        Button(action: {
                            showCreateGroupSheet.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .opacity(isSidebarOpen ? 0 : 1) // Hide when sidebar is open
                    }
                )
                .sheet(isPresented: $showCreateGroupSheet) {
                    CreateGroupView { newGroup in
                        groups.insert(newGroup, at: 0) // Prepend newGroup to the groups array
                    }
                }
                .alert(isPresented: $showAlert) {
                    if actionType == .delete {
                        return Alert(
                            title: Text("Delete Group"),
                            message: Text("Are you sure you want to delete this group? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                deleteGroup(selectedGroup!)
                            },
                            secondaryButton: .cancel()
                        )
                    } else {
                        return Alert(
                            title: Text("Leave Group"),
                            message: Text("Are you sure you want to leave this group?"),
                            primaryButton: .destructive(Text("Leave")) {
                                leaveGroup(selectedGroup!)
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }

    func fetchCurrentUser() {
        UserController.shared.fetchCurrentUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let currentUser):
                    // Save user ID to UserSession
                    UserSession.shared.userId = currentUser.id
                    self.currentUser = currentUser
                    let firstNameInitial = currentUser.firstname?.first ?? Character("?")
                    let lastNameInitial = currentUser.lastname?.first ?? Character("?")
                    currentUserInitials = "\(firstNameInitial)\(lastNameInitial)"
                    fetchInvitationCount() // Fetch invitation count after fetching the current user
                case .failure(let error):
                    print("Error fetching current user:", error)
                }
            }
        }
    }

    func fetchGroups() {
        GroupController.shared.fetchGroups { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedGroups):
                    groups = fetchedGroups
                    isLoading = false
                case .failure(let error):
                    fetchError = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    func fetchInvitationCount() {
        GroupMembershipController.shared.fetchInvitationCount { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let count):
                    invitationCount = count
                case .failure(let error):
                    print("Error fetching invitation count:", error)
                }
            }
        }
    }

    func deleteGroup(_ group: Group) {
        GroupController.shared.deleteGroup(groupId: group.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = groups.firstIndex(where: { $0.id == group.id }) {
                        groups.remove(at: index)
                    }
                case .failure(let error):
                    fetchError = error.localizedDescription
                }
            }
        }
    }

    func leaveGroup(_ group: Group) {
        guard let userId = UserSession.shared.userId else {
            fetchError = "User not logged in."
            return
        }
        
        GroupMembershipController.shared.deleteGroupMembership(groupId: group.id, userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = groups.firstIndex(where: { $0.id == group.id }) {
                        groups.remove(at: index)
                    }
                case .failure(let error):
                    fetchError = error.localizedDescription
                }
            }
        }
    }

    func isAdmin(of group: Group) -> Bool {
        guard let currentUserId = UserSession.shared.userId else {
            return false
        }
        return group.administrators?.contains(currentUserId) ?? false
    }
}
