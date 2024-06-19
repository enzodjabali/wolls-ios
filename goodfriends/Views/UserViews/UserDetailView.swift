import SwiftUI

struct UserDetailView: View {
    var user: User
    @Environment(\.presentationMode) var presentationMode
    @State private var copiedIBAN = false
    @Environment(\.colorScheme) var colorScheme

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
                        .foregroundColor(.primary)
                }

                Text("@" + user.pseudonym)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, -10)

                VStack(alignment: .leading, spacing: 10) {
                    // Role Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Status".uppercased())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        HStack {
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
                            Spacer()
                        }
                        .padding()
                        .background(boxBackgroundColor)
                        .cornerRadius(10)
                    }

                    // Email Section
                    // if let email = user.email {
                    //    VStack(alignment: .leading, spacing: 5) {
                    //        Text("Email".uppercased())
                    //            .font(.subheadline)
                    //            .foregroundColor(.gray)
                    //        HStack {
                    //            Text(email)
                    //                .font(.subheadline)
                    //                .foregroundColor(.gray)
                    //            Spacer()
                    //        }
                    //        .padding()
                    //        .background(boxBackgroundColor)
                    //        .cornerRadius(10)
                    //    }
                    // }

                    // IBAN Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("IBAN".uppercased())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        HStack {
                            if let iban = user.iban, !iban.isEmpty {
                                Text(iban)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            } else {
                                Text("IBAN not provided")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                            }
                            Spacer()
                            if let iban = user.iban, !iban.isEmpty {
                                Button(action: {
                                    UIPasteboard.general.string = iban
                                    copiedIBAN = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        copiedIBAN = false
                                    }
                                }) {
                                    Text("Copy")
                                        .foregroundColor(.blue)
                                }
                                .alert(isPresented: $copiedIBAN) {
                                    Alert(
                                        title: Text("IBAN Copied"),
                                        dismissButton: .default(Text("OK"))
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(boxBackgroundColor)
                        .cornerRadius(10)
                    }

                    // Balance Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Balance".uppercased())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        HStack {
                            if let balance = user.balance {
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
                                } else {
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
                            Spacer()
                        }
                        .padding()
                        .background(boxBackgroundColor)
                        .cornerRadius(10)
                    }
                }
                .padding([.leading, .trailing], 20)

                Spacer() // Pushes content to the top
            }
            .padding()
            .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all)) // Set the background that adapts to light/dark mode
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

    private var boxBackgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground)
    }
}
