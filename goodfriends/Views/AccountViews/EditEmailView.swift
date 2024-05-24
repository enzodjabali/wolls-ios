import SwiftUI

struct EditEmailView: View {
    @State private var email: String
    @Environment(\.presentationMode) var presentationMode

    init(email: String) {
        _email = State(initialValue: email)
    }

    var body: some View {
        Form {
            Section(header: Text("Edit Email")) {
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            
            Button(action: {
                // Handle save action
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
            }
        }
        .navigationTitle("Edit Email")
    }
}
