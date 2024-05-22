import SwiftUI

struct GroupDetailView: View {
    @State private var selectedTab = 0
    @State private var isEditing = false
    @State private var newName = ""
    @State private var newDescription = ""
    let groupId: String
    let groupName: String
    let groupDescription: String
    
    var body: some View {
        VStack {
            Picker(selection: $selectedTab, label: Text("")) {
                Text("Expenses").tag(0)
                Text("Refunds").tag(1)
                Text("Balances").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            viewForSelectedTab()
        }
        .navigationTitle(groupName)
        .navigationBarItems(trailing:
            Button(action: {
                isEditing.toggle()
            }) {
                Text(isEditing ? "Done" : "Edit")
            }
        )
        .sheet(isPresented: $isEditing) {
            EditGroupView(groupId: groupId, groupName: groupName, isEditing: $isEditing, newName: $newName, newDescription: $newDescription)
        }
        .onAppear {
            // Prefill the fields with current data
            newName = groupName
            newDescription = groupDescription
        }
    }
    
    @ViewBuilder
    private func viewForSelectedTab() -> some View {
        switch selectedTab {
        case 0:
            ExpensesView(groupId: groupId)
        case 1:
            RefundsView()
        case 2:
            BalancesView()
        default:
            Text("Select a tab")
        }
    }
}

struct EditGroupView: View {
    let groupId: String
    let groupName: String
    @Binding var isEditing: Bool
    @State private var editError: String?
    @Binding var newName: String
    @Binding var newDescription: String
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Name")) {
                    TextField("Enter new name", text: $newName)
                }
                Section(header: Text("New Description")) {
                    TextField("Enter new description", text: $newDescription)
                }
                if let error = editError {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Group")
            .navigationBarItems(leading: Button("Cancel") {
                isEditing = false
            }, trailing: Button("Save") {
                editGroup()
            })
        }
    }
    
    func editGroup() {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "https://api.goodfriends.tech/v1/groups/\(groupId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let updatedGroup = ["name": newName, "description": newDescription]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: updatedGroup, options: []) else { return }
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    editError = error.localizedDescription
                }
                return
            }

            guard let data = data else { return }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Group updated successfully
                DispatchQueue.main.async {
                    isEditing = false
                }
            } else {
                // Handle error
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorMessage = jsonResponse["error"] as? String {
                    DispatchQueue.main.async {
                        editError = errorMessage
                    }
                } else {
                    DispatchQueue.main.async {
                        editError = "An unknown error occurred"
                    }
                }
            }
        }.resume()
    }
}
