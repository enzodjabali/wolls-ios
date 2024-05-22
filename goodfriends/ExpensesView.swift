import SwiftUI

struct Expense: Identifiable {
    let id: UUID
    let title: String
    let amount: Double
    // Other properties
    
    init(id: UUID = UUID(), title: String, amount: Double) {
        self.id = id
        self.title = title
        self.amount = amount
    }
}

struct ExpensesView: View {
    let groupId: String
    @State private var expenses: [Expense] = []
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
                List(expenses) { expense in
                    Text(expense.title)
                }
            }
        }
        .onAppear {
            fetchExpenses()
        }
    }
    
    func fetchExpenses() {
        guard let url = URL(string: "https://api.goodfriends.tech/v1/expenses/\(groupId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle response
        }.resume()
    }
}
