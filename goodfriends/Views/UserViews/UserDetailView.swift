import SwiftUI

struct UserDetailView: View {
    var user: User
    
    var body: some View {
        VStack(spacing: 16) {
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
        }
        .padding()
    }
    
    private func userInitials(_ user: User) -> String {
        let firstInitial = user.firstname?.first ?? "?"
        let lastInitial = user.lastname?.first ?? "?"
        return "\(firstInitial)\(lastInitial)"
    }
}
