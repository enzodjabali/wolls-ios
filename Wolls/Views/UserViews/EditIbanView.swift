import SwiftUI

struct EditIbanView: View {
    @State private var newIban: String
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    var iban: String

    init(iban: String) {
        self.iban = iban
        _newIban = State(initialValue: iban)
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Edit IBAN")) {
                    TextField("IBAN", text: $newIban)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("IBAN")
            .navigationBarItems(
                trailing: Button("Save") {
                    updateIban()
                }
            )

            Text("This makes it easier for your friends to send your reimbursements. To ensure smooth transactions, provide an accurate and active IBAN.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
        }
    }

    private func updateIban() {
        UserController.shared.editUserIban(newIban: newIban) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedUser):
                    // Handle successful iban update
                    print("IABN updated successfully: \(updatedUser.iban)")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    // Handle error
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
