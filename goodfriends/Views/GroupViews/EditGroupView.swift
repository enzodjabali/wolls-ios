import SwiftUI

struct EditGroupView: View {
    let groupId: String
    let groupName: String
    @Binding var isEditing: Bool
    @State private var editError: String?
    @Binding var newName: String
    @Binding var newDescription: String
    
    var body: some View {
        NavigationView {
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
            .navigationTitle("Edit Group")
            .navigationBarItems(leading: Button("Cancel") {
                isEditing = false
            }, trailing: Button("Save") {
                editGroup()
            })
        }
    }
    
    func editGroup() {
        GroupController.shared.editGroup(groupId: groupId, newName: newName, newDescription: newDescription) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    isEditing = false
                case .failure(let error):
                    editError = error.localizedDescription
                }
            }
        }
    }
}
