import SwiftUI

struct Group: Identifiable, Decodable {
    let _id: String
    let name: String
    let description: String

    var id: String { _id }
}

struct GroupsView: View {
    @State private var groups: [Group] = []
    @State private var fetchError: String?
    @State private var isLoading: Bool = true

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let error = fetchError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(groups) { group in
                    NavigationLink(destination: GroupDetailView(groupId: group.id)) {
                        VStack(alignment: .leading) {
                            Text(group.name)
                                .font(.headline)
                            Text(group.description)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchGroups()
        }
        .navigationTitle("Groups")
        .navigationBarBackButtonHidden(true) // This line hides the back button
    }

    func fetchGroups() {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "https://api.goodfriends.tech/v1/groups") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    fetchError = error.localizedDescription
                    isLoading = false
                }
                return
            }

            guard let data = data else { return }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let jsonResponse = try? JSONDecoder().decode([Group].self, from: data) {
                    DispatchQueue.main.async {
                        self.groups = jsonResponse
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        fetchError = "Failed to parse groups"
                        isLoading = false
                    }
                }
            } else {
                // Handle error
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorMessage = jsonResponse["error"] as? String {
                    DispatchQueue.main.async {
                        fetchError = errorMessage
                        isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        fetchError = "An unknown error occurred"
                        isLoading = false
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    GroupsView()
}
