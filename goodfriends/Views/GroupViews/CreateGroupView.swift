import SwiftUI

struct CreateGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var groupName = ""
    @State private var groupDescription = ""
    @State private var createError: String?
    var onCreate: (Group) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Name")) {
                    TextField("Enter group name", text: $groupName)
                }
                Section(header: Text("Description")) {
                    TextField("Enter description", text: $groupDescription)
                }
                if let error = createError {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Create a group")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Create") {
                createGroup()
            })
        }
    }

    func createGroup() {
        GroupController.shared.createGroup(name: groupName, description: groupDescription) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newGroup):
                    onCreate(newGroup)
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }
}
