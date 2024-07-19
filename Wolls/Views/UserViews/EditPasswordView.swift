import SwiftUI

struct EditPasswordView: View {
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Change Password")) {
                    SecureField("Current Password", text: $currentPassword)
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm New Password", text: $confirmPassword)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Password")
            .navigationBarItems(
                trailing: Button("Save") {
                    updatePassword()
                }
            )

            Text("To help keep your account safe, choose a strong password.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
        }
    }

    private func updatePassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "New password and confirmation do not match"
            return
        }

        UserController.shared.updatePassword(currentPassword: currentPassword, newPassword: newPassword, confirmPassword: confirmPassword) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Handle successful password update
                    print("Password updated successfully")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    // Handle error
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
