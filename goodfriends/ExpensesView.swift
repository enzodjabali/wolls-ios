import SwiftUI

import Foundation

struct Expense: Identifiable, Decodable {
    let id: String // Assuming _id in JSON is a String
    let title: String
    let amount: Double
    let date: String // Assuming date is in String format
    let creator_id: String
    let creator_pseudonym: String
    let group_id: String
    let category: String
    let refund_recipients: [String]
    let isRefunded: Bool
    let __v: Int
    
    // You can add additional properties if needed
    
    // Define CodingKeys enum to map JSON keys to Swift properties
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case amount
        case date
        case creator_id
        case creator_pseudonym
        case group_id
        case category
        case refund_recipients
        case isRefunded
        case __v
    }
    
    // Implement custom decoding to handle specific cases, if necessary
    // If the date format is not standard, you may need to implement custom date decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        amount = try container.decode(Double.self, forKey: .amount)
        date = try container.decode(String.self, forKey: .date)
        creator_id = try container.decode(String.self, forKey: .creator_id)
        creator_pseudonym = try container.decode(String.self, forKey: .creator_pseudonym)
        group_id = try container.decode(String.self, forKey: .group_id)
        category = try container.decode(String.self, forKey: .category)
        refund_recipients = try container.decode([String].self, forKey: .refund_recipients)
        isRefunded = try container.decode(Bool.self, forKey: .isRefunded)
        __v = try container.decode(Int.self, forKey: .__v)
    }
}

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
            
            // Button to add an expense
            Button(action: {
                showAddExpenseSheet.toggle()
            }) {
                Text("Add Expense")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
        }
        .onAppear {
            fetchExpenses()
        }
        .onChange(of: searchText) { value in
            filterExpenses()
        }
        .sheet(isPresented: $showAddExpenseSheet) {
            AddExpenseView(groupId: groupId) { newExpense in
                expenses.append(newExpense)
            }
        }
    }

    func fetchExpenses() {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "https://api.goodfriends.tech/v1/expenses/\(groupId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // Assuming the date is in ISO 8601 format

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                if let error = error {
                    fetchError = error.localizedDescription
                } else {
                    fetchError = "No data received"
                }
                isLoading = false
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
            }

            print("Raw data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")

            do {
                expenses = try decoder.decode([Expense].self, from: data)
                isLoading = false
                filterExpenses() // Filter expenses initially
            } catch {
                fetchError = "Failed to decode expenses: \(error.localizedDescription)"
                isLoading = false
            }
        }.resume()
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
                .onChange(of: text) { _ in
                    // Automatically update the text while typing
                    // If you prefer to search only after pressing the return key, remove this line
                }
            if !text.isEmpty {
                Button(action: {
                    // Clear the text when the clear button is tapped
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .padding(.horizontal)
                }
            }
        }
    }
}

struct AddExpenseView: View {
    let groupId: String
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var amountString = ""
    @State private var category = ""
    @State private var createError: String?
    var onAdd: (Expense) -> Void

    // Existing code...

    var body: some View {
        // Form to enter expense details
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amountString)
                        .keyboardType(.decimalPad)
                    TextField("Category", text: $category)
                }
                if let error = createError {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                createExpense()
            })
        }
    }

    // Existing code...

    func createExpense() {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let amount = Double(amountString),
              let url = URL(string: "https://api.goodfriends.tech/v1/expenses") else { return }

        let newExpense: [String: Any] = ["title": title, "amount": amount, "group_id": groupId, "category": category]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: newExpense, options: []) else { return }
 
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
                if let jsonResponse = try? JSONDecoder().decode(Expense.self, from: data) {
                    DispatchQueue.main.async {
                        onAdd(jsonResponse)
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
                        createError = "Failed to create expense"
                    }
                }
            }
        }.resume()
    }
}
