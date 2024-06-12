import SwiftUI

struct UserDetailView: View {
    var user: User
    @Environment(\.presentationMode) var presentationMode
    @State private var copiedIBAN = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Spacer() // Pushes content to the top
                
                AvatarViewProfile(initials: userInitials(user))
                    .frame(width: 200, height: 200)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white.opacity(0.4)]), startPoint: .bottom, endPoint: .top)
                            .clipShape(Circle())
                    )
                
                if let firstname = user.firstname, let lastname = user.lastname {
                    Text("\(firstname) \(lastname)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Text("@" + user.pseudonym)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, -10)
                
                if let email = user.email {
                    Text("Email: \(email)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                if let iban = user.iban {
                    if !iban.isEmpty {
                        Text("IBAN: \(iban)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text("IBAN not provided by the user.")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
                
                if let iban = user.iban, !iban.isEmpty {
                    Button(action: {
                        UIPasteboard.general.string = iban
                        copiedIBAN = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedIBAN = false
                        }
                    }) {
                        Text("Copy IBAN")
                            .foregroundColor(.blue)
                    }
                    .alert(isPresented: $copiedIBAN) {
                        Alert(
                            title: Text("IBAN Copied"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                
                Spacer() // Pushes content to the top
            }
            .padding()
            .navigationBarTitle("", displayMode: .inline) // Empty title to remove the default title
            .navigationBarItems(leading:
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .foregroundColor(.blue)
                }
            )
        }
    }
    
    private func userInitials(_ user: User) -> String {
        let firstInitial = user.firstname?.first ?? "?"
        let lastInitial = user.lastname?.first ?? "?"
        return "\(firstInitial)\(lastInitial)"
    }
}
