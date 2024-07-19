import SwiftUI

struct RegisterView: View {
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var pseudonym: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var registerError: String?
    @Binding var isLoggedIn: Bool // Updated to use the same Binding for login status

    var body: some View {
        ScrollView {
            // Wolls logo image
            Image("logo-wolls")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100) // Adjust size as needed

            // Form fields
            TextField("First name", text: $firstname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disableAutocorrection(true)

            TextField("Last name", text: $lastname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disableAutocorrection(true)

            TextField("Username", text: $pseudonym)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()
                .disableAutocorrection(true)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disableAutocorrection(true)

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disableAutocorrection(true)

            if let error = registerError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }

            // Introductory text before the Register button
            Text("Youhou, it's your time to Wooooolls!")
                .font(.headline)
                .padding()
                .foregroundColor(Color(red: 132/255, green: 193/255, blue: 255/255)) // Using custom RGB color

            Button(action: {
                register()
            }) {
                Text("Register")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            NavigationLink(destination: LoginView(isLoggedIn: $isLoggedIn), isActive: $isLoggedIn) {
                EmptyView()
            }
        }
        .padding()
        .navigationTitle("Register")
    }

    func register() {
        UserController.shared.register(
            firstname: firstname,
            lastname: lastname,
            pseudonym: pseudonym,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    UserDefaults.standard.set(token, forKey: "userToken")
                    isLoggedIn = true
                case .failure(let error):
                    registerError = error.localizedDescription
                }
            }
        }
    }
}
