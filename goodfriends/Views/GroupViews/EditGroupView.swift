import SwiftUI

struct EditGroupView: View {
    @ObservedObject var viewModel: GroupDetailsViewModel
    @Binding var isEditing: Bool
    @State private var newName: String
    @State private var newDescription: String
    @State private var createdAtDate: Date? // New state variable for createdAt
    @State private var editError: String?
    @State private var deleteError: String?
    @State private var showDeleteAlert = false
    @State private var showLeaveAlert = false
    @Environment(\.presentationMode) var presentationMode

    init(viewModel: GroupDetailsViewModel, isEditing: Binding<Bool>) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._isEditing = isEditing
        self._newName = State(initialValue: viewModel.groupName)
        self._newDescription = State(initialValue: viewModel.groupDescription)
        self._createdAtDate = State(initialValue: DateFormatter.iso8601Full.date(from: viewModel.createdAt)) // Initialize createdAtDate
    }

    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Enter new name", text: $newName)
                    .disabled(!isAdmin)
            }
            Section(header: Text("Description")) {
                TextField("Enter new description", text: $newDescription)
                    .disabled(!isAdmin)
            }
            Section(header: Text("Creation Date")) {
                if let createdAtDate = createdAtDate {
                    Text("\(createdAtDate, formatter: dateFormatter)")
                        .foregroundColor(.gray) // Make the text look disabled
                } else {
                    Text("Invalid date")
                }
            }
            if let error = editError {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            if let error = deleteError {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            if !isOnlyAdmin {
                Section {
                    Button(action: {
                        showLeaveAlert = true
                    }) {
                        Text("Leave Group")
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                    }
                }
                .alert(isPresented: $showLeaveAlert) {
                    Alert(
                        title: Text("Leave Group"),
                        message: Text("Are you sure you want to leave this group?"),
                        primaryButton: .destructive(Text("Leave")) {
                            leaveGroup()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            if isAdmin {
                Section {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Text("Delete Group")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Delete Group"),
                        message: Text("Are you sure you want to delete this group? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteGroup()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .navigationTitle("Group")
        .navigationBarItems(trailing: Button("Save") {
            editGroup()
        }
        .disabled(!isAdmin))

        if !isAdmin {
            Text("You are not an administrator of this group and cannot edit it.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
        }
    }

    private var isAdmin: Bool {
        guard let currentUserId = UserSession.shared.userId else {
            return false
        }
        return viewModel.administrators.contains(currentUserId)
    }
    
    private var isOnlyAdmin: Bool {
        guard let currentUserId = UserSession.shared.userId else {
            return false
        }
        return viewModel.administrators.count == 1 && viewModel.administrators.contains(currentUserId)
    }

    func editGroup() {
        guard isAdmin else {
            editError = "You are not authorized to edit this group."
            return
        }
        
        GroupController.shared.editGroup(groupId: viewModel.groupId, newName: newName, newDescription: newDescription) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    viewModel.updateGroupName(newName)
                    viewModel.updateGroupDescription(newDescription)
                    isEditing = false
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    editError = error.localizedDescription
                }
            }
        }
    }

    func deleteGroup() {
        guard isAdmin else {
            deleteError = "You are not authorized to delete this group."
            return
        }
        
        GroupController.shared.deleteGroup(groupId: viewModel.groupId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    deleteError = error.localizedDescription
                }
            }
        }
    }
    
    func leaveGroup() {
        guard let userId = UserSession.shared.userId else {
            deleteError = "User not logged in."
            return
        }
        
        GroupMembershipController.shared.deleteGroupMembership(groupId: viewModel.groupId, userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    deleteError = error.localizedDescription
                }
            }
        }
    }

    // DateFormatter to format createdAtDate
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
