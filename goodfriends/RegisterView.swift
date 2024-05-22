import SwiftUI

struct RegisterView: View {
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var pseudonym: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var registerError: String?
    @State private var isRegistered: Bool = false

    var body: some View {
        VStack {
            TextField("First Name", text: $firstname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disableAutocorrection(true)
            
            TextField("Last Name", text: $lastname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disableAutocorrection(true)
            
            TextField("Pseudonym", text: $pseudonym)
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
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            NavigationLink(destination: LoginView(), isActive: $isRegistered) {
                EmptyView()
            }
        }
        .padding()
        .navigationTitle("Register")
    }

    func register() {
        guard let url = URL(string: "https://api.goodfriends.tech/v1/users/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let registerDetails: [String: Any] = [
            "firstname": firstname,
            "lastname": lastname,
            "pseudonym": pseudonym,
            "email": email,
            "password": password,
            "confirmPassword": confirmPassword
        ]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: registerDetails, options: []) else { return }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    registerError = error.localizedDescription
                }
                return
            }

            guard let data = data else { return }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                // Successful registration
                DispatchQueue.main.async {
                    isRegistered = true
                }
            } else {
                // Handle error
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorMessage = jsonResponse["error"] as? String {
                    DispatchQueue.main.async {
                        registerError = errorMessage
                    }
                } else {
                    DispatchQueue.main.async {
                        registerError = "An unknown error occurred"
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    RegisterView()
}
