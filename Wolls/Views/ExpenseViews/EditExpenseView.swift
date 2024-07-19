import SwiftUI
import UIKit
import MobileCoreServices

struct EditExpenseView: View {
    let groupId: String
    let expenseId: String
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var amountString = ""
    @State private var selectedCategory = "No category"
    @State private var createError: String?
    @State private var members = [User]()
    @State private var selectedMembers = [User]()
    @State private var searchText = ""
    @State private var currentUser: User?
    
    @State private var showImagePicker = false
    @State private var showDocumentPicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var base64ImageString: String?
    @State private var base64FileString: String?
    @State private var fileName: String?
    
    @State private var showActionSheet = false
    @State private var isLoading = true
    @State private var isRefunded = false
    
    @State private var isCreator = false
    
    let categories = ["No category", "Accommodation", "Entertainment", "Groceries", "Restaurants & Bars", "Shopping", "Transport", "Healthcare", "Insurance"]
    
    var onUpdate: (Expense) -> Void

    var body: some View {
        VStack {
            Form {
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    Section(header: Text("Expense Details")) {
                        TextField("Title", text: $title)
                            .disabled(!isCreator)
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) {
                                Text($0)
                            }
                        }
                        .disabled(!isCreator)
                        HStack {
                            TextField("Amount", text: $amountString)
                                .keyboardType(.decimalPad)
                                .disabled(!isCreator)
                            Text("€")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
            
                    Section(header: Text("Recipients")) {
                        TextField("Search users by username", text: $searchText)
                        
                        List {
                            ForEach(filteredMembers) { member in
                                HStack {
                                    Text(member.pseudonym)
                                        .foregroundColor(.blue)
                                    Spacer()
                                    if selectedMembers.contains(where: { $0.id == member.id }) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if isCreator {
                                        if let index = selectedMembers.firstIndex(where: { $0.id == member.id }) {
                                            selectedMembers.remove(at: index)
                                        } else {
                                            selectedMembers.append(member)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
//                    Section(header: Text("Receipt")) {
//                        if let selectedImage = selectedImage {
//                            Image(uiImage: selectedImage)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: 200)
//                            
//                            if isCreator {
//                                Button(action: shareAttachment) {
//                                    HStack {
//                                        Image(systemName: "square.and.arrow.up")
//                                        Text("Share")
//                                    }
//                                    .foregroundColor(.blue)
//                                }
//
//                                Button(action: removeAttachment) {
//                                    HStack {
//                                        Image(systemName: "minus.circle")
//                                        Text("Remove")
//                                    }
//                                    .foregroundColor(.red)
//                                }
//                            }
//                        } else if let base64FileString = base64FileString {
//                            if let imageData = Data(base64Encoded: base64FileString),
//                               let uiImage = UIImage(data: imageData) {
//                                Image(uiImage: uiImage)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(height: 200)
//                            } else {
//                                if let fileName = fileName {
//                                    Text("\(fileName)")
//                                }
//                            }
//                            
//                            if isCreator {
//                                Button(action: shareAttachment) {
//                                    HStack {
//                                        Image(systemName: "square.and.arrow.up")
//                                        Text("Share")
//                                    }
//                                    .foregroundColor(.blue)
//                                }
//
//                                Button(action: removeAttachment) {
//                                    HStack {
//                                        Image(systemName: "minus.circle")
//                                        Text("Remove")
//                                    }
//                                    .foregroundColor(.red)
//                                }
//                            }
//                        } else {
//                            if isCreator {
//                                Button("Add a receipt") {
//                                    self.showActionSheet = true
//                                }
//                            }
//                        }
//                    }
                    
                    Section {
                        Toggle("Refunded", isOn: $isRefunded)
                            .disabled(!isCreator)
                    }
                
                    if let error = createError {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                fetchGroupMembers()
                fetchCurrentUser()
                fetchExpenseDetails()
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(title: Text("Add Attachment"), buttons: [
                    .default(Text("Select Picture")) {
                        self.imagePickerSourceType = .photoLibrary
                        self.showImagePicker = true
                    },
                    .default(Text("Take Picture")) {
                        self.imagePickerSourceType = .camera
                        self.showImagePicker = true
                    },
                    .default(Text("Select File")) {
                        self.showDocumentPicker = true
                    },
                    .cancel()
                ])
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: self.imagePickerSourceType, selectedImage: self.$selectedImage, base64ImageString: self.$base64ImageString)
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(base64FileString: self.$base64FileString, fileName: self.$fileName)
            }
        }
        .navigationTitle("Expense")
        .navigationBarItems(
            trailing: Button("Save") {
                if isCreator {
                    updateExpense()
                }
            }
            .disabled(!isCreator)
        )
        if !isCreator {
            Text("You can only view this expense. Editing is allowed only for the creator.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
        }
    }
    
    var filteredMembers: [User] {
        if searchText.isEmpty {
            return members
        } else {
            return members.filter { $0.pseudonym.lowercased().contains(searchText.lowercased()) }
        }
    }

    func fetchExpenseDetails() {
        ExpenseController.shared.fetchExpense(groupId: groupId, expenseId: expenseId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let expense):
                    self.title = expense.title
                    self.amountString = String(expense.amount)
                    self.selectedCategory = expense.category
                    self.isRefunded = expense.isRefunded

                    if let attachment = expense.attachment {
                        self.fileName = attachment.fileName
                        self.base64FileString = attachment.content
                    }

                    // Set selectedMembers based on refund_recipients
                    self.selectedMembers = self.members.filter { expense.refund_recipients.contains($0.id) }
                    
                    // Check if the current user is the creator of the expense
                    if let currentUserId = UserSession.shared.userId {
                        self.isCreator = (currentUserId == expense.creator_id)
                    }
                    
                case .failure(let error):
                    self.createError = error.localizedDescription
                }
                self.isLoading = false
            }
        }
    }
    
    func fetchGroupMembers() {
        GroupMembershipController.shared.fetchGroupMembers(groupId: groupId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.members = users
                    self.fetchExpenseDetails() // Fetch expense details after members have been fetched
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
                case .failure(let error):
                    print("Failed to fetch current user: \(error)")
                }
            }
        }
    }

    func updateExpense() {
        guard let amount = Double(amountString) else {
            createError = "Invalid amount"
            return
        }
        
        let refundRecipientIds = selectedMembers.map { $0.id }
        
        var attachment: [String: Any]?
        if let base64ImageString = base64ImageString, let selectedImage = selectedImage {
            attachment = [
                "filename": "image.png",
                "content": base64ImageString
            ]
        } else if let base64FileString = base64FileString, let fileName = fileName {
            attachment = [
                "filename": fileName,
                "content": base64FileString
            ]
        }

        var updatedExpense: [String: Any] = [
            "title": title,
            "amount": amount,
            "category": selectedCategory,
            "refund_recipients":
                refundRecipientIds,
                "isRefunded": isRefunded
        ]

        if let attachment = attachment {
            updatedExpense["attachment"] = attachment
        }

        ExpenseController.shared.updateExpense(expenseId: expenseId, with: updatedExpense) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedExpense):
                    onUpdate(updatedExpense)
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }
        
    func shareAttachment() {
        guard let base64FileString = base64FileString else {
            return
        }

        let imageData = Data(base64Encoded: base64FileString)
        let activityViewController = UIActivityViewController(activityItems: [imageData!], applicationActivities: nil)

        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
        
    func removeAttachment() {
        ExpenseController.shared.deleteExpenseAttachment(expenseId: expenseId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Reset the attachment related states
                    self.selectedImage = nil
                    self.base64ImageString = nil
                    self.base64FileString = nil
                    self.fileName = nil
                case .failure(let error):
                    createError = error.localizedDescription
                }
            }
        }
    }
}
