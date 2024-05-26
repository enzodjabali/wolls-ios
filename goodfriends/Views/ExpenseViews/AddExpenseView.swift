import SwiftUI

struct AddExpenseView: View {
    let groupId: String
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var amountString = ""
    @State private var selectedCategory = "No category" // Default category
    @State private var createError: String?
    @State private var members = [User]()
    @State private var selectedMembers = [User]()
    @State private var searchText = ""
    @State private var currentUser: User? // Track current user
    var onAdd: (Expense) -> Void

    let categories = ["No category", "Accommodation", "Entertainment", "Groceries", "Restaurants & Bars", "Shopping", "Transport", "Healthcare", "Insurance"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amountString)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                }

                Section(header: Text("Recipients")) {
                    TextField("Search users by username", text: $searchText)
                    
                    List {
                        ForEach(filteredMembers) { member in
                            HStack {
                                Text(member.pseudonym)
                                    .foregroundColor(.blue) // Apply blue color here
                                Spacer()
                                if selectedMembers.contains(where: { $0.id == member.id }) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue) // Apply blue color here
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let index = selectedMembers.firstIndex(where: { $0.id == member.id }) {
                                    selectedMembers.remove(at: index)
                                } else {
                                    selectedMembers.append(member)
                                }
                            }
                        }
                    }
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
            .onAppear {
                fetchGroupMembers()
                fetchCurrentUser()
            }
        }
    }

    var filteredMembers: [User] {
        if searchText.isEmpty {
            return members
        } else {
            return members.filter { $0.pseudonym.lowercased().contains(searchText.lowercased()) }
        }
    }

    func fetchGroupMembers() {
        GroupMembershipController.shared.fetchGroupMembers(groupId: groupId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.members = users
                case .failure(let error):
                    self.createError = error.localizedDescription
                }
            }
        }
    }
    
    func fetchCurrentUser() {
        UserController.shared.fetchCurrentUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.currentUser = user
                    // Add current user to selected members by default
                    if let currentUser = self.currentUser {
                        self.selectedMembers.append(currentUser)
                    }
                case .failure(let error):
                    print("Failed to fetch current user: \(error)")
                }
            }
        }
    }

    func createExpense() {
        guard let amount = Double(amountString) else {
            createError = "Invalid amount"
            return
        }
        
        let refundRecipientIds = selectedMembers.map { $0.id }
        
        // Add current user to selected members by default if available
        if let currentUser = currentUser, !selectedMembers.contains(where: { $0.id == currentUser.id }) {
            selectedMembers.append(currentUser)
        }

        ExpenseController.shared.createExpense(groupId: groupId, title: title, amount: amount, category: selectedCategory, refundRecipients: refundRecipientIds) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newExpense):
                    onAdd(newExpense)
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }
}
