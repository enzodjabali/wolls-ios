import SwiftUI

struct EditUsernameView: View {
    @State private var newUsername: String
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    var username: String

    init(username: String) {
        self.username = username
        _newUsername = State(initialValue: username)
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Edit Username")) {
                    TextField("Username", text: $newUsername)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Username")
            .navigationBarItems(
                trailing: Button("Save") {
                    updateUsername()
                }
            )

            Text("This is how your friends find and add you to their groups.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
        }
    }

    private func updateUsername() {
        UserController.shared.editUserUsername(newUsername: newUsername) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedUser):
                    // Handle successful username update
                    print("Username updated successfully: \(updatedUser.pseudonym)")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    // Handle error
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
