import SwiftUI

struct GroupDetailsView: View {
    @State private var selectedTab = 0
    @State private var isEditing = false
    @State private var newName = ""
    @State private var newDescription = ""
    let groupId: String
    let groupName: String
    let groupDescription: String
    
    var body: some View {
        VStack {
            Picker(selection: $selectedTab, label: Text("")) {
                Text("Expenses").tag(0)
                Text("Refunds").tag(1)
                Text("Balances").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            viewForSelectedTab()
        }
        .navigationTitle(groupName)
        .navigationBarItems(trailing:
            Button(action: {
                isEditing.toggle()
            }) {
                Text(isEditing ? "Done" : "Edit")
            }
        )
        .sheet(isPresented: $isEditing) {
            EditGroupView(groupId: groupId, groupName: groupName, isEditing: $isEditing, newName: $newName, newDescription: $newDescription)
        }
        .onAppear {
            // Prefill the fields with current data
            newName = groupName
            newDescription = groupDescription
        }
    }
    
    @ViewBuilder
    private func viewForSelectedTab() -> some View {
        switch selectedTab {
        case 0:
            ExpensesView(groupId: groupId)
        case 1:
            RefundsView()
        case 2:
            BalancesView()
        default:
            Text("Select a tab")
        }
    }
}

