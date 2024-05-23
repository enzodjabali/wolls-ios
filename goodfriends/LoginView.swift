
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
                Image("login") // Replace "your_image_name" with the name of your image asset
                    .resizable()
                    .scaledToFit()
                    .frame(width: 270, height: 270) // Adjust size as needed
                
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
            .navigationTitle("Login")
        }
    }

    func login() {
        guard let url = URL(string: "https://api.goodfriends.tech/v1/users/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginDetails = ["pseudonym": pseudonym, "password": password]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: loginDetails, options: []) else { return }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    loginError = error.localizedDescription
                }
                return
            }

            guard let data = data else { return }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = jsonResponse["token"] as? String {
                    // Successful login
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(token, forKey: "userToken")
                        isLoggedIn = true // Update login status
                    }
                } else {
                    DispatchQueue.main.async {
                        loginError = "Failed to parse token"
                    }
                }
            } else {
                // Handle error
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorMessage = jsonResponse["error"] as? String {
                    DispatchQueue.main.async {
                        loginError = errorMessage
                    }
                } else {
                    DispatchQueue.main.async {
                        loginError = "An unknown error occurred"
                    }
                }
            }
        }.resume()
    }
}
