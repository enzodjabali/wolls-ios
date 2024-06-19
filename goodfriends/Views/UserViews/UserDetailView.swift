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
                
                if user.is_administrator == true {
                    Text("Administrator")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(5)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(5)
                } else {
                    Text("Member")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(5)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(5)
                }
                
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
                
                if let balance = user.balance {
                    HStack {
                        if balance < 0 {
                            Rectangle()
                                .fill(Color.red.opacity(0.8)) // Set opacity here
                                .cornerRadius(5) // Set corner radius here
                                .frame(width: max(CGFloat(abs(balance) / maxBalance) * maxBarWidth, 80), height: 25) // Ensure minimum width
                                .overlay(
                                    Text("\(String(format: "%.2f", balance)) €")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                )
                                .padding(.horizontal, 5) // Add horizontal padding for better spacing
                        }
                        if balance > 0 {
                            Rectangle()
                                .fill(Color.green.opacity(0.8)) // Set opacity here
                                .cornerRadius(5) // Set corner radius here
                                .frame(width: max(CGFloat(balance / maxBalance) * maxBarWidth, 80), height: 25) // Ensure minimum width
                                .overlay(
                                    Text("\(String(format: "%.2f", balance)) €")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                )
                                .padding(.horizontal, 5) // Add horizontal padding for better spacing
                        }
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
    
    private var maxBalance: Float {
        return 1000 // Replace with your logic to determine the maximum balance
    }

    private var maxBarWidth: CGFloat {
        return 200 // Replace with your desired maximum bar width
    }
}
