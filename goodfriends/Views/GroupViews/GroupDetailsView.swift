import SwiftUI
import Combine

struct GroupDetailsView: View {
    @StateObject private var viewModel: GroupDetailsViewModel
    @State private var selectedTab = 0
    @State private var isEditing = false
    @State private var isInviting = false
    
    init(groupId: String, groupName: String, groupDescription: String, groupCreatedAt: String, administrators: [String]) {
        _viewModel = StateObject(wrappedValue: GroupDetailsViewModel(groupId: groupId, groupName: groupName, groupDescription: groupDescription, createdAt: groupCreatedAt, administrators: administrators))
    }
    
    var body: some View {
        VStack {
            Picker(selection: $selectedTab, label: Text("")) {
                Text("Expenses").tag(0)
                Text("Refunds").tag(1)
                Text("Balances").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            viewForSelectedTab()
        }
        .navigationTitle(viewModel.groupName)
        .navigationBarItems(trailing: HStack {
            if viewModel.isAdmin {
                Image(systemName: "person.badge.key")
                    .imageScale(.large)
            }
            NavigationLink(destination: EditGroupView(viewModel: viewModel, isEditing: $isEditing), isActive: $isEditing) {
                Button(action: {
                    isEditing.toggle()
                }) {
                    Image(systemName: "gear")
                        .imageScale(.large)
                }
            }
            NavigationLink(destination: CreateInvitationView(groupId: viewModel.groupId, onCreate: {}), isActive: $isInviting) {
                Button(action: {
                    isInviting.toggle()
                }) {
                    Image(systemName: "person.2")
                        .imageScale(.large)
                }
            }
        })
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
    @Published var groupName: String
    @Published var groupDescription: String
    @Published var createdAt: String
    @Published var administrators: [String]
    
    private var currentUserId: String? {
        return UserSession.shared.userId
    }
    
    init(groupId: String, groupName: String, groupDescription: String, createdAt: String, administrators: [String]) {
        self.groupId = groupId
        self.groupName = groupName
        self.groupDescription = groupDescription
        self.createdAt = createdAt
        self.administrators = administrators
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
