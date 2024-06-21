import SwiftUI
import Combine

struct GroupDetailsView: View {
    @StateObject private var viewModel: GroupDetailsViewModel
    @State private var selectedTab = 0
    @State private var isEditing = false
    @State private var isInviting = false
    @Binding var isLoggedIn: Bool
    
    init(groupId: String, isLoggedIn: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: GroupDetailsViewModel(groupId: groupId))
        _isLoggedIn = isLoggedIn
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let error = viewModel.fetchError {
                Text(error)
                    .foregroundColor(.red)
            } else {
                Picker(selection: $selectedTab, label: Text("")) {
                    Text("Expenses").tag(0)
                    Text("Refunds").tag(1)
                    Text("Balances").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                viewForSelectedTab()
            }
        }
        .navigationTitle(viewModel.groupName)
        .navigationBarItems(trailing: HStack {
            NavigationLink(destination: EditGroupView(viewModel: viewModel, isEditing: $isEditing, isLoggedIn: $isLoggedIn), isActive: $isEditing) {
                Button(action: {
                    isEditing.toggle()
                }) {
                    Image(systemName: "info.circle")
                        .imageScale(.large)
                }
            }
            NavigationLink(destination: CreateInvitationView(groupId: viewModel.groupId, onCreate: {
                viewModel.fetchGroupDetails() // Fetch latest details when invitation is created
            }), isActive: $isInviting) {
                Button(action: {
                    isInviting.toggle()
                }) {
                    Image(systemName: "person.2")
                        .imageScale(.large)
                }
            }
        })
        .onAppear {
            viewModel.fetchGroupDetails() // Ensure the view fetches details when it appears
        }
    }
    
    @ViewBuilder
    private func viewForSelectedTab() -> some View {
        switch selectedTab {
        case 0:
            ExpensesView(groupId: viewModel.groupId)
        case 1:
            RefundsView(groupId: viewModel.groupId)
        case 2:
            BalancesView(groupId: viewModel.groupId)
        default:
            Text("Select a tab")
        }
    }
}

class GroupDetailsViewModel: ObservableObject {
    @Published var groupId: String
    @Published var groupName: String = ""
    @Published var groupDescription: String = ""
    @Published var createdAt: String = ""
    @Published var administrators: [String] = []
    @Published var isLoading: Bool = true
    @Published var fetchError: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private var currentUserId: String? {
        return UserSession.shared.userId
    }
    
    init(groupId: String) {
        self.groupId = groupId
        fetchGroupDetails()
    }
    
    func fetchGroupDetails() {
        GroupController.shared.fetchGroup(by: groupId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let group):
                    self.groupName = group.name
                    self.groupDescription = group.description ?? ""
                    self.createdAt = group.createdAt ?? ""
                    self.administrators = group.administrators ?? []
                case .failure(let error):
                    self.fetchError = error.localizedDescription
                }
            }
        }
    }
    
    var isAdmin: Bool {
        return currentUserId != nil && administrators.contains(currentUserId!)
    }
    
    func updateGroupName(_ newName: String) {
        self.groupName = newName
    }
    
    func updateGroupDescription(_ newDescription: String) {
        self.groupDescription = newDescription
    }
}
