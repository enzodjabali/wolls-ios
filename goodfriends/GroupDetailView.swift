import SwiftUI

struct GroupDetailView: View {
    @State private var selectedTab = 0
    @State private var groupName: String = ""
    let groupId: String
    
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
        .onAppear {
            fetchGroupName()
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
    
    private func fetchGroupName() {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "https://api.goodfriends.tech/v1/groups/\(groupId)") else {
            print("Invalid URL or missing token")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let decodedResponse = try? JSONDecoder().decode(GroupDetailResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.groupName = decodedResponse.name
                }
            } else {
                print("Failed to decode group name from API.")
            }
        }.resume()
    }
}

struct GroupDetailResponse: Decodable {
    let name: String
}
