import SwiftUI

struct EditNameView: View {
    @State private var newFirstName: String
    @State private var newLastName: String
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    var firstName: String
    var lastName: String

    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
        _newFirstName = State(initialValue: firstName)
        _newLastName = State(initialValue: lastName)
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Edit Name")) {
                    TextField("First Name", text: $newFirstName)
                        .autocapitalization(.words)
                    TextField("Last Name", text: $newLastName)
                        .autocapitalization(.words)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Name")
            .navigationBarItems(
                trailing: Button("Save") {
                    updateName(firstName: newFirstName, lastName: newLastName)
                }
            )

            Text("This is how your name appears in your profile.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
        }
    }

    private func updateName(firstName: String, lastName: String) {
        UserController.shared.editUserName(newFirstName: firstName, newLastName: lastName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedUser):
                    // Handle successful name update
                    print("Name updated successfully: \(updatedUser.firstname) \(updatedUser.lastname)")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    // Handle error
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
