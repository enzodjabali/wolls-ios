import SwiftUI

struct AddExpenseView: View {
    let groupId: String
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var amountString = ""
    @State private var category = ""
    @State private var createError: String?
    @State private var members = [User]()
    @State private var selectedMembers = [User]()
    @State private var searchText = ""
    var onAdd: (Expense) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amountString)
                        .keyboardType(.decimalPad)
                    TextField("Category", text: $category)
                }
                
                Section(header: Text("Refund Recipients")) {
                    TextField("Search", text: $searchText)
                    
                    List {
                        ForEach(filteredMembers) { member in
                            HStack {
                                Text(member.pseudonym)
                                Spacer()
                                if selectedMembers.contains(where: { $0.id == member.id }) {
                                    Image(systemName: "checkmark")
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

    func createExpense() {
        guard let amount = Double(amountString) else {
            createError = "Invalid amount"
            return
        }
        
        let refundRecipientIds = selectedMembers.map { $0.id }

        ExpenseController.shared.createExpense(groupId: groupId, title: title, amount: amount, category: category, refundRecipients: refundRecipientIds) { result in
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
