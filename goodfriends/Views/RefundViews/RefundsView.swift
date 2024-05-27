import SwiftUI

struct RefundsView: View {
    @State private var refunds: [RefundSimplified] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

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
                } else if refunds.isEmpty {
                    Text("No refunds to display.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                } else {
                    List(refunds) { refund in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(refund.creatorPseudonym) owes \(refund.recipientPseudonym)")
                                    .font(.headline)
                                Text("\(refund.refundAmount, specifier: "%.2f") €")
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .onAppear(perform: loadRefunds)
        }
    }

    private func loadRefunds() {
        RefundController.shared.fetchRefunds(groupId: groupId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let refunds):
                    self.refunds = refunds
                case .failure(let error):
                    self.errorMessage = "Failed to load refunds: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
}
