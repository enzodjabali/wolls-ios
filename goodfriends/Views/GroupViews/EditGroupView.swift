import SwiftUI

struct EditGroupView: View {
    @ObservedObject var viewModel: GroupDetailsViewModel
    @Binding var isEditing: Bool
    @State private var newName: String
    @State private var newDescription: String
    @State private var editError: String?
    @Environment(\.presentationMode) var presentationMode
    
    init(viewModel: GroupDetailsViewModel, isEditing: Binding<Bool>) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._isEditing = isEditing
        self._newName = State(initialValue: viewModel.groupName)
        self._newDescription = State(initialValue: viewModel.groupDescription)
    }
    
    var body: some View {
        Form {
            Section(header: Text("New Name")) {
                TextField("Enter new name", text: $newName)
            }
            Section(header: Text("New Description")) {
                TextField("Enter new description", text: $newDescription)
            }
            if let error = editError {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Group")
        .navigationBarItems(trailing: Button("Save") {
            editGroup()
        })
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
}
