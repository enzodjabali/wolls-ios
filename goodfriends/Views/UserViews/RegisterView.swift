import SwiftUI

struct RegisterView: View {
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var pseudonym: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var registerError: String?
    @State private var isRegistered = false
    
    var body: some View {
        VStack {
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

            NavigationLink(destination: LoginView(isLoggedIn: $isRegistered), isActive: $isRegistered) {
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
                case .success:
                    isRegistered = true
                case .failure(let error):
                    registerError = error.localizedDescription
                }
            }
        }
    }
}


