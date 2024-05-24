import SwiftUI

struct GroupsView: View {
    @State private var groups: [Group] = []
    @State private var fetchError: String?
    @State private var isLoading: Bool = true
    @State private var showCreateGroupSheet = false
    @State private var currentUser: User?
    @State private var currentUserInitials = ""
    @State private var isSidebarOpen = false
    @Binding var isLoggedIn: Bool

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
                                        NavigationLink(destination: GroupDetailsView(groupId: group.id, groupName: group.name, groupDescription: group.description)) {
                                            GroupBoxView(group: group)
                                        }
                                    }
                                    .onDelete(perform: deleteGroup)
                                    .listRowSeparator(.hidden)
                                }
                                .listStyle(PlainListStyle())
                                .transition(.opacity)
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
                        SidebarView(user: currentUser)
                            .frame(width: 300)
                            .transition(.move(edge: .leading))
                            .zIndex(3)
                    }
                }
                .onAppear {
                    fetchCurrentUser()
                    fetchGroups()
                }
                .navigationTitle("Groups")
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(
                    leading: AvatarView(initials: currentUserInitials)
                        .onTapGesture {
                            withAnimation {
                                isSidebarOpen.toggle()
                            }
                        }
                        .frame(width: 35, height: 35) // Adjust size
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white.opacity(0.4)]), startPoint: .bottom, endPoint: .top)
                                .clipShape(Circle())
                        ),
                    trailing: Button(action: {
                        showCreateGroupSheet.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                )
                .sheet(isPresented: $showCreateGroupSheet) {
                    CreateGroupView { newGroup in
                        groups.append(newGroup)
                    }
                }
            }
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }

    func fetchCurrentUser() {
        UserController.shared.fetchCurrentUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let currentUser):
                    self.currentUser = currentUser
                    // Construct initials from first and last name
                    let firstNameInitial = currentUser.firstname.first ?? Character("")
                    let lastNameInitial = currentUser.lastname.first ?? Character("")
                    currentUserInitials = "\(firstNameInitial)\(lastNameInitial)"
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

    func deleteGroup(at offsets: IndexSet) {
        offsets.forEach { index in
            let group = groups[index]
            GroupController.shared.deleteGroup(groupId: group.id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        groups.remove(at: index)
                    case .failure(let error):
                        fetchError = error.localizedDescription
                    }
                }
            }
        }
    }
}
