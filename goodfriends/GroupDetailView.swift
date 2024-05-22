import SwiftUI

struct GroupDetailView: View {
    @State private var selectedTab = 0
    let groupId: String
    let groupName: String
    
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
