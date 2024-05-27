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
                    HStack {
                        Text(balance.username)
                            .font(.headline)
                        
                        Spacer()
                        
                        HStack {
                            if balance.amount < 0 {
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(width: CGFloat(abs(balance.amount) / maxBalance) * maxBarWidth, height: 20)
                            } else {
                                Spacer().frame(width: maxBarWidth)
                            }
                            
                            if balance.amount > 0 {
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: CGFloat(balance.amount / maxBalance) * maxBarWidth, height: 20)
                            }
                        }
                        
                        Text("\(String(format: "%.2f", balance.amount)) €")
                            .font(.subheadline)
                            .padding(.leading, 8)
                    }
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
