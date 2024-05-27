import SwiftUI

struct ExpensesView: View {
    let groupId: String
    @State private var expenses: [Expense] = []
    @State private var filteredExpenses: [Expense] = []
    @State private var fetchError: String?
    @State private var isLoading: Bool = true
    @State private var searchText: String = ""
    @State private var showAddExpenseSheet = false
    @State private var selectedExpense: Expense?
    @State private var userTotalAmount: Double = 0
    @State private var groupTotalAmount: Double = 0
    @State private var amountsError: String?

    private let categoryColors: [String: Color] = [
        "No category": Color.gray,
        "Accommodation": Color.brown,
        "Entertainment": Color.orange,
        "Groceries": Color.green,
        "Restaurants & Bars": Color.red,
        "Shopping": Color.purple,
        "Transport": Color.yellow,
        "Healthcare": Color.pink,
        "Insurance": Color.black
    ]

    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Assuming the input format is this
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "dd/MM/yyyy"
            return dateFormatter.string(from: date)
        } else {
            return "Invalid Date"
        }
    }

    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Search")
            
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let error = fetchError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List {
                    ForEach(filteredExpenses.isEmpty ? expenses : filteredExpenses, id: \.id) { expense in
                        NavigationLink(destination: EditExpenseView(groupId: groupId, expenseId: expense.id, onUpdate: { updatedExpense in
                            if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
                                expenses[index] = updatedExpense
                            }
                        })) {
                            VStack(alignment: .leading) {
                                HStack(spacing: 3) {
                                    // Badge with category color
                                    let badgeColor = categoryColors[expense.category] ?? Color.gray
                                    Text("•")
                                        .font(.system(size: 40)) // Adjust the font size here
                                        .foregroundColor(badgeColor)
                                        .padding(.bottom, 3)
                                    
                                    Text(expense.title)
                                        .font(.headline)
                                        .padding(.leading, -3) // Adjust the padding here if needed
                                    
                                    Spacer()
    
                                    Text("\(String(format: "%.2f", expense.amount)) €")
                                        .font(.headline)
                                }
                                .padding(.bottom, -15)
                                .padding(.top, -15)
                                
                                HStack {
                                    if let pseudonym = expense.creator_pseudonym {
                                        Text("Paid by \(pseudonym)")
                                            .font(.subheadline)
                                    } else {
                                        Text("Paid by Unknown")
                                            .font(.subheadline)
                                    }
                                    Spacer()
                                    Text(formatDate(expense.date))
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteExpense)
                }
                .refreshable {
                    self.fetchExpenses()
                }
                
                if let amountsError = amountsError {
                    Text(amountsError)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    HStack {
                        VStack {
                            Text("My total".uppercased())
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Text("\(String(format: "%.2f", userTotalAmount)) €")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()

                        VStack {
                            Text("Group total".uppercased())
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Text("\(String(format: "%.2f", groupTotalAmount)) €")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()
                    }
                    .padding(.vertical, -10)
                }
            }
        }
        .onAppear {
            fetchExpenses()
            fetchTotalAmounts()
        }
        .onChange(of: searchText) { value in
            filterExpenses()
        }
        .navigationBarItems(trailing: Button(action: {
            showAddExpenseSheet.toggle()
        }) {
            Image(systemName: "plus")
                .font(.title2)
        })
        .sheet(isPresented: $showAddExpenseSheet) {
            AddExpenseView(groupId: groupId) { newExpense in
                expenses.append(newExpense)
                fetchExpenses()
                fetchTotalAmounts()
            }
        }
    }

    func fetchExpenses() {
        ExpenseController.shared.fetchExpenses(groupId: groupId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let expenses):
                    self.expenses = expenses
                    self.isLoading = false
                    self.filterExpenses() // Filter expenses initially
                case .failure(let error):
                    self.fetchError = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func fetchTotalAmounts() {
        ExpenseController.shared.fetchTotalAmounts(groupId: groupId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let amounts):
                    self.userTotalAmount = amounts.userTotalAmount / 100.0
                    self.groupTotalAmount = amounts.groupTotalAmount / 100.0
                case .failure(let error):
                    self.amountsError = error.localizedDescription
                }
            }
        }
    }

    func filterExpenses() {
        if searchText.isEmpty {
            filteredExpenses = expenses
        } else {
            filteredExpenses = expenses.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    func deleteExpense(at offsets: IndexSet) {
        guard let expenseIndex = offsets.first else { return }
        let expenseId = filteredExpenses.isEmpty ? expenses[expenseIndex].id : filteredExpenses[expenseIndex].id

        // Perform the delete API call
        ExpenseController.shared.deleteExpense(expenseId: expenseId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Remove the expense from the local array
                    if filteredExpenses.isEmpty {
                        expenses.remove(at: expenseIndex)
                    } else {
                        if let index = expenses.firstIndex(where: { $0.id == expenseId }) {
                            expenses.remove(at: index)
                        }
                    }
                    fetchTotalAmounts()
                case .failure(let error):
                    // Handle error
                    print("Error deleting expense: \(error)")
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .padding(.horizontal)
                }
            }
        }
    }
}
