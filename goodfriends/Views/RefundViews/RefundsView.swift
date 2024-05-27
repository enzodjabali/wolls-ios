import SwiftUI

struct RefundsView: View {
    @State private var refundsSimplified: [RefundSimplified] = []
    @State private var refundsDetailed: [RefundDetailed] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showSimplified = true

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
        NavigationView {
            VStack {
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
                            Text("No simplified refunds to display.")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        } else {
                            List(refundsSimplified) { refund in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(refund.recipientPseudonym) owes \(refund.creatorPseudonym)")
                                            .font(.headline)
                                        Text("\(refund.refundAmount, specifier: "%.2f") €")
                                            .font(.subheadline)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    } else {
                        if refundsDetailed.isEmpty {
                            Text("No detailed refunds to display.")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        } else {
                            List(refundsDetailed) { refund in
                                VStack(alignment: .leading) {
                                    HStack {
                                        // Badge with category color
                                        let badgeColor = categoryColors[refund.expenseCategory] ?? Color.gray
                                        Text("•")
                                            .font(.system(size: 40)) // Adjust the font size here
                                            .foregroundColor(badgeColor)

                                        Text(refund.expenseTitle)
                                            .font(.headline)
                                            .padding(.leading, 5) // Adjust the padding here if needed

                                        Spacer()
                                    }
                                    ForEach(refund.refundRecipients) { recipient in
                                        HStack {
                                            Text("\(recipient.recipientPseudonym) owes")
                                            Spacer()
                                            Text("\(recipient.refundAmount, specifier: "%.2f") €")
                                        }
                                    }
                                    Text("To \(refund.creatorPseudonym)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }

                Toggle("Simplified view", isOn: $showSimplified)
                    .padding()
                    .onChange(of: showSimplified) { _ in
                        loadRefunds()
                    }
            }
            .onAppear(perform: loadRefunds)
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
