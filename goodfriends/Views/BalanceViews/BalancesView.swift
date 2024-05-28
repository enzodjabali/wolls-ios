import SwiftUI

struct BalancesView: View {
    let groupId: String
    @State private var balances: [Balance] = []
    @State private var fetchError: String?
    @State private var isLoading: Bool = true

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let error = fetchError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(balances) { balance in
                    VStack(alignment: .leading) {
                        if balance.amount < 0 {
                            Text(balance.username)
                                .font(.headline)
                                .foregroundColor(Color(red: 0.40, green: 0.40, blue: 0.40))
                        } else {
                            HStack {
                                Spacer()
                                Text(balance.username)
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.40, green: 0.40, blue: 0.40))
                            }
                        }
                        
                        HStack {
                            if balance.amount < 0 {
                                Rectangle()
                                    .fill(Color.red.opacity(0.8)) // Set opacity here
                                    .cornerRadius(5) // Set corner radius here
                                    .frame(width: CGFloat(abs(balance.amount) / maxBalance) * maxBarWidth * 1.5, height: 25)
                                    .overlay(
                                        Text("\(String(format: "%.2f", balance.amount)) €")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    )
                            }
                            if balance.amount > 0 {
                                Spacer()
                                Rectangle()
                                    .fill(Color.green.opacity(0.8)) // Set opacity here
                                    .cornerRadius(5) // Set corner radius here
                                    .frame(width: CGFloat(balance.amount / maxBalance) * maxBarWidth * 1.5, height: 25)
                                    .overlay(
                                        Text("\(String(format: "%.2f", balance.amount)) €")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    )
                                    .padding(.vertical, 5)
                            }
                        }
                    }
                }
                .refreshable {
                    fetchBalances()
                }
            }
        }
        .onAppear {
            fetchBalances()
        }
    }

    private var maxBalance: Double {
        return balances.map { abs($0.amount) }.max() ?? 1
    }

    private var maxBarWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.4 // Adjust the max width of the bar as needed
    }

    private func fetchBalances() {
        BalanceController.shared.fetchBalances(groupId: groupId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let balances):
                    self.balances = balances
                    self.isLoading = false
                case .failure(let error):
                    self.fetchError = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
