import SwiftUI
import Foundation

struct ExpensesView: View {
    let groupId: String
    @State private var expenses: [Expense] = []
    @State private var filteredExpenses: [Expense] = []
    @State private var fetchError: String?
    @State private var isLoading: Bool = true
    @State private var searchText: String = ""
    @State private var showAddExpenseSheet = false

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
            SearchBar(text: $searchText, placeholder: "Search Expenses")
            
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let error = fetchError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(filteredExpenses.isEmpty ? expenses : filteredExpenses) { expense in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(expense.title)
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.2f", expense.amount))
                                .font(.headline)
                        }
                        HStack {
                            Text("Paid by \(expense.creator_pseudonym)")
                                .font(.subheadline)
                            Spacer()
                            Text(formatDate(expense.date))
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchExpenses()
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

    func filterExpenses() {
        if searchText.isEmpty {
            filteredExpenses = expenses
        } else {
            filteredExpenses = expenses.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
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
