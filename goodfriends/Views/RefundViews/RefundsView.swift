import SwiftUI

struct RefundsView: View {
    @State private var refundsSimplified: [RefundSimplified] = []
    @State private var refundsDetailed: [RefundDetailed] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showSimplified = true

    let groupId: String

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
                                    Text("\(refund.creatorPseudonym)'s expense: \(refund.expenseTitle)")
                                        .font(.headline)
                                    Text("Category: \(refund.expenseCategory)")
                                        .font(.subheadline)
                                    ForEach(refund.refundRecipients) { recipient in
                                        HStack {
                                            Text("\(recipient.recipientPseudonym) owes")
                                            Spacer()
                                            Text("\(recipient.refundAmount, specifier: "%.2f") €")
                                        }
                                    }
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
