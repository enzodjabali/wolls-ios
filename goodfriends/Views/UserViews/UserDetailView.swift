import SwiftUI

struct UserDetailView: View {
    var user: User
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Spacer() // Pushes content to the top
                
                AvatarView(initials: userInitials(user))
                    .frame(width: 100, height: 100)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white.opacity(0.4)]), startPoint: .bottom, endPoint: .top)
                            .clipShape(Circle())
                    )
                
                Text(user.pseudonym)
                    .font(.title)
                    .fontWeight(.bold)
                
                if let firstname = user.firstname, let lastname = user.lastname {
                    Text("\(firstname) \(lastname)")
                        .font(.subheadline)
                }
                
                if let email = user.email {
                    Text("Email: \(email)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                if let iban = user.iban {
                    Text("IBAN: \(iban)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
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
