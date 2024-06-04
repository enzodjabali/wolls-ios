import SwiftUI

struct RefundsView: View {
    @State private var refundsSimplified: [RefundSimplified] = []
    @State private var refundsDetailed: [RefundDetailed] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showSimplified = true
    @State private var searchText = ""

    let groupId: String

    private let categoryColors: [String: Color] = [
        "No category": Color.gray,
        "Accommodation": Color.brown,
        "Entertainment": Color.orange,
        "Groceries": Color.green,
        "Restaurants & Bars": Color.red,
        "Shopping": Color.purple,
        "Transport": Color.yellow,
        "Healthcare": Color.pink,
        "Insurance": Color.black
    ]

    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Search")
            
            if isLoading {
                ProgressView("Loading refunds...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else {
                if showSimplified {
                    if refundsSimplified.isEmpty {
                        Spacer()
                        Text("No simplified refunds to display.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Spacer()
                    } else {
                        List(filteredSimplifiedRefunds) { refund in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(refund.recipientPseudonym) owes \(refund.creatorPseudonym)")
                                        .font(.headline)
                                    Text(String(format: "%.2f €", refund.refundAmount))
                                        .font(.subheadline)
                                }
                                Spacer()
                            }
                        }
                        .refreshable {
                            loadRefunds()
                        }
                    }
                } else {
                    if refundsDetailed.isEmpty {
                        Spacer()
                        Text("No detailed refunds to display.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Spacer()
                    } else {
                        List(filteredDetailedRefunds) { refund in
                            NavigationLink(destination: EditExpenseView(groupId: groupId, expenseId: refund.expenseId, onUpdate: { updatedExpense in
                                // Handle the update
                            })) {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 3) {
                                        // Badge with category color
                                        let badgeColor = categoryColors[refund.expenseCategory] ?? Color.gray
                                        Text("•")
                                            .font(.system(size: 40)) // Adjust the font size here
                                            .foregroundColor(badgeColor)
                                            .padding(.bottom, 3)

                                        Text(refund.expenseTitle)
                                            .font(.headline)
                                            .padding(.leading, -3) // Adjust the padding here if needed

                                        Spacer()
                                    }
                                    .padding(.bottom, -15)
                                    .padding(.top, -15)

                                    ForEach(refund.refundRecipients) { recipient in
                                        HStack {
                                            Text("\(recipient.recipientPseudonym) owes")
                                            Spacer()
                                            Text(String(format: "%.2f €", recipient.refundAmount))
                                        }
                                    }
                                    Text("To \(refund.creatorPseudonym)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .refreshable {
                            loadRefunds()
                        }
                    }
                }
            }

            Toggle("Simplified view", isOn: $showSimplified)
                .padding(.horizontal, 30)
                .padding(.top, 5)
                .onChange(of: showSimplified) { _ in
                    loadRefunds()
                }
        }
        .onAppear(perform: loadRefunds)
    }

    private var filteredSimplifiedRefunds: [RefundSimplified] {
        if searchText.isEmpty {
            return refundsSimplified
        } else {
            return refundsSimplified.filter { refund in
                refund.recipientPseudonym.lowercased().contains(searchText.lowercased()) ||
                refund.creatorPseudonym.lowercased().contains(searchText.lowercased()) ||
                String(format: "%.2f", refund.refundAmount).contains(searchText)
            }
        }
    }

    private var filteredDetailedRefunds: [RefundDetailed] {
        if searchText.isEmpty {
            return refundsDetailed
        } else {
            return refundsDetailed.filter { refund in
                refund.expenseTitle.lowercased().contains(searchText.lowercased()) ||
                refund.creatorPseudonym.lowercased().contains(searchText.lowercased()) ||
                refund.refundRecipients.contains(where: { recipient in
                    recipient.recipientPseudonym.lowercased().contains(searchText.lowercased()) ||
                    String(format: "%.2f", recipient.refundAmount).contains(searchText)
                })
            }
        }
    }

    private func loadRefunds() {
        isLoading = true
        errorMessage = nil
        if showSimplified {
            RefundController.shared.fetchRefunds(groupId: groupId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let refunds):
                        self.refundsSimplified = refunds
                    case .failure(let error):
                        self.errorMessage = "Failed to load refunds: \(error.localizedDescription)"
                    }
                    self.isLoading = false
                }
            }
        } else {
            RefundController.shared.fetchDetailedRefunds(groupId: groupId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let refunds):
                        self.refundsDetailed = refunds
                    case .failure(let error):
                        self.errorMessage = "Failed to load refunds: \(error.localizedDescription)"
                    }
                    self.isLoading = false
                }
            }
        }
    }
}
