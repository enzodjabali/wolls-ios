import SwiftUI

struct EditDetailView: View {
    @State private var value: String
    let title: String
    @Environment(\.presentationMode) var presentationMode

    init(title: String, value: String) {
        self.title = title
        _value = State(initialValue: value)
    }

    var body: some View {
        Form {
            Section(header: Text("Edit \(title)")) {
                TextField(title, text: $value)
            }
            
            Button(action: {
                // Handle save action
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
            }
        }
        .navigationTitle("Edit \(title)")
    }
}
