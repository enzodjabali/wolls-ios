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
    @State private var showCreateGroupSheet = false

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
                if groups.isEmpty {
                    VStack {
                        Image("nothing")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 250, height: 250)
                            .foregroundColor(.gray)
                        
                        Text("You don't have any groups yet.")
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showCreateGroupSheet.toggle()
                        }) {
                            Text("Create Your First Group")
                                .foregroundColor(.blue)
                                .padding()
                        }
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(groups) { group in
                                NavigationLink(destination: GroupDetailView(groupId: group.id, groupName: group.name, groupDescription: group.description)) {
                                    GroupBoxView(group: group)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            fetchGroups()
        }
        .navigationTitle("Groups")
        .navigationBarItems(trailing: Button(action: {
            showCreateGroupSheet.toggle()
        }) {
            Image(systemName: "plus")
                .font(.title2)
        })
        .sheet(isPresented: $showCreateGroupSheet) {
            CreateGroupView { newGroup in
                groups.append(newGroup)
            }
        }
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

    func deleteGroup(at offsets: IndexSet) {
        guard let token = UserDefaults.standard.string(forKey: "userToken") else { return }

        offsets.forEach { index in
            let group = groups[index]
            guard let url = URL(string: "https://api.goodfriends.tech/v1/groups/\(group.id)") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue(token, forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        fetchError = error.localizedDescription
                    }
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        groups.remove(at: index)
                    }
                } else {
                    if let data = data,
                       let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = jsonResponse["error"] as? String {
                        DispatchQueue.main.async {
                            fetchError = errorMessage
                        }
                    } else {
                        DispatchQueue.main.async {
                            fetchError = "Failed to delete group"
                        }
                    }
                }
            }.resume()
        }
    }
}

struct GroupBoxView: View {
    let group: Group

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("group-background-buildings") // Placeholder for the background image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .cornerRadius(10)

            Color.blue.opacity(0.3)
                .cornerRadius(10)

            VStack(alignment: .leading) {
                Text(group.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding([.top, .leading], 8)
                    .shadow(radius: 1)
                Text(group.description)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding([.leading, .bottom], 8)
                    .shadow(radius: 1)
            }
        }
        .frame(height: 150)
    }
}

struct CreateGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var groupName = ""
    @State private var groupDescription = ""
    @State private var createError: String?
    var onCreate: (Group) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Name")) {
                    TextField("Enter group name", text: $groupName)
                }
                Section(header: Text("Description")) {
                    TextField("Enter description", text: $groupDescription)
                }
                if let error = createError {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Create Group")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Create") {
                createGroup()
            })
        }
    }

    func createGroup() {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "https://api.goodfriends.tech/v1/groups") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let newGroup = ["name": groupName, "description": groupDescription]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: newGroup, options: []) else { return }
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    createError = error.localizedDescription
                }
                return
            }

            guard let data = data else { return }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                if let jsonResponse = try? JSONDecoder().decode(Group.self, from: data) {
                    DispatchQueue.main.async {
                        onCreate(jsonResponse)
                        presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    DispatchQueue.main.async {
                        createError = "Failed to parse response"
                    }
                }
            } else {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorMessage = jsonResponse["error"] as? String {
                    DispatchQueue.main.async {
                        createError = errorMessage
                    }
                } else {
                    DispatchQueue.main.async {
                        createError = "Failed to create group"
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    GroupsView()
}
