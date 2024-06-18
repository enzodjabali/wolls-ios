import SwiftUI

struct LoginView: View {
    @State private var pseudonym: String = ""
    @State private var password: String = ""
    @State private var loginError: String?
    @Binding var isLoggedIn: Bool // Binding for login status

    init(isLoggedIn: Binding<Bool>) {
        _isLoggedIn = isLoggedIn
    }

    var body: some View {
        NavigationView {
            VStack {
                Image("logo-wolls")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 230, height: 230)
                
                Text("Wollscome!")
                    .font(.custom("Arial Rounded MT Bold", size: 36)) // Custom font and size
                    .foregroundColor(.blue)
                    .padding(.top, 20)

                TextField("Username", text: $pseudonym)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if let error = loginError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: {
                    login()
                }) {
                    Text("Login")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account? Register here.")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .padding()
            //.navigationTitle("Login")
        }
    }

    func login() {
        UserController.shared.login(pseudonym: pseudonym, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    UserDefaults.standard.set(token, forKey: "userToken")
                    isLoggedIn = true
                case .failure(let error):
                    loginError = error.localizedDescription
                }
            }
        }
    }
}
