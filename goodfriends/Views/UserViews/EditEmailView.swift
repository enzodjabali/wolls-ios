import SwiftUI

struct EditEmailView: View {
    @State private var newEmail: String
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    var email: String

    init(email: String) {
        self.email = email
        _newEmail = State(initialValue: email)
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Edit Email")) {
                    TextField("Email", text: $newEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Email")
            .navigationBarItems(
                trailing: Button("Save") {
                    updateEmail()
                }
            )

            Text("This makes it easier for you to recover your account. To help keep your account safe, only use an email address that you know.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
        }
    }

    private func updateEmail() {
        UserController.shared.editUserEmail(newEmail: newEmail) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedUser):
                    // Handle successful email update
                    print("Email updated successfully: \(updatedUser.email)")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    // Handle error
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
