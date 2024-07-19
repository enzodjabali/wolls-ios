import SwiftUI
import UIKit
import MobileCoreServices

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
    @State private var showImagePicker = false
    @State private var showDocumentPicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var base64ImageString: String?
    @State private var base64FileString: String?
    @State private var fileName: String?
    @State private var showActionSheet = false

    var onAdd: (Expense) -> Void

    let categories = ["No category", "Accommodation", "Entertainment", "Groceries", "Restaurants & Bars", "Shopping", "Transport", "Healthcare", "Insurance"]

    var body: some View {
        NavigationView {
            Form {
                if let error = createError {
                    Text(error)
                        .foregroundColor(.red)
                }
                Section(header: Text("Expense Details")) {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                    HStack {
                        TextField("Amount", text: $amountString)
                            .keyboardType(.decimalPad)
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

//                Section(header: Text("Receipt")) {
//                    if selectedImage == nil && fileName == nil {
//                        Button(action: {
//                            self.showActionSheet = true
//                        }) {
//                            Text("Add a receipt")
//                        }
//                    }
//                    if let selectedImage = selectedImage {
//                        Image(uiImage: selectedImage)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 200)
//                        Button(action: {
//                            self.selectedImage = nil
//                            base64ImageString = nil
//                        }) {
//                            Text("Remove Image")
//                                .foregroundColor(.red)
//                        }
//                    }
//                    if let fileName = fileName {
//                        Text("\(fileName)")
//                        Button(action: {
//                            self.fileName = nil
//                            base64FileString = nil
//                        }) {
//                            HStack {
//                                Image(systemName: "minus.circle")
//                                Text("Remove")
//                            }
//                            .foregroundColor(.red)
//                        }
//                    }
//                }

            }
            .navigationTitle("Expense")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                createExpense()
            })
            .onAppear {
                fetchGroupMembers()
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
                    self.selectCurrentUser()
                case .failure(let error):
                    self.createError = error.localizedDescription
                }
            }
        }
    }

    func selectCurrentUser() {
        if let userId = UserSession.shared.userId {
            // Find the current user in the members list
            if let currentUser = members.first(where: { $0.id == userId }) {
                self.currentUser = currentUser
                if !selectedMembers.contains(where: { $0.id == currentUser.id }) {
                    selectedMembers.append(currentUser)
                }
            } else {
                print("Current user is not in the group members list")
            }
        } else {
            print("User ID is not available")
        }
    }

    func createExpense() {
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

        var newExpense: [String: Any] = [
            "title": title,
            "amount": amount,
            "group_id": groupId,
            "category": selectedCategory,
            "refund_recipients": refundRecipientIds
        ]

        if let attachment = attachment {
            newExpense["attachment"] = attachment
        }

        ExpenseController.shared.createExpense(with: newExpense) { result in
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

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Binding var base64ImageString: String?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
                if let imageData = uiImage.pngData() {
                    parent.base64ImageString = imageData.base64EncodedString()
                }
            }
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var base64FileString: String?
    @Binding var fileName: String?

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first, let fileData = try? Data(contentsOf: url) {
                parent.base64FileString = fileData.base64EncodedString()
                parent.fileName = url.lastPathComponent
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String, kUTTypePDF as String], in: .import)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

