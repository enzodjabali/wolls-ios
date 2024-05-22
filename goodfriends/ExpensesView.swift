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
