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
                Text(error)
                    .foregroundColor(.red)
            }
            if let error = deleteError {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Group")
        .navigationBarItems(trailing: Button("Save") {
            editGroup()
        }
        .disabled(!isAdmin))
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
        if isAdmin {
            Button(action: {
                showDeleteAlert = true
            }) {
                Text("Delete Group")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }

    private var isAdmin: Bool {
        guard let currentUserId = UserSession.shared.userId else {
            return false
        }
        return viewModel.administrators.contains(currentUserId)
    }

    func editGroup() {
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
