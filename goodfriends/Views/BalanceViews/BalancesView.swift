import SwiftUI

struct BalancesView: View {
    let groupId: String
    @State private var balances: [UserStatus] = []
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
                if balances.isEmpty {
                    ScrollView {
                        ZStack {
                            Spacer().containerRelativeFrame([.horizontal, .vertical])
                            VStack {
                                Text("No balances to display.")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                    }
                    .refreshable {
                        fetchBalances()
                    }
                } else {
                    List {
                        ForEach(balances.indices, id: \.self) { index in
                            let balance = balances[index]
                            VStack(alignment: .leading) {
                                if let amount = balance.balance, amount < 0 {
                                    Text(balance.pseudonym)
                                        .font(.headline)
                                } else {
                                    HStack {
                                        Spacer()
                                        Text(balance.pseudonym)
                                            .font(.headline)
                                    }
                                }

                                HStack {
                                    if let amount = balance.balance, amount < 0 {
                                        Rectangle()
                                            .fill(Color.red.opacity(0.8)) // Set opacity here
                                            .cornerRadius(5) // Set corner radius here
                                            .frame(width: max(CGFloat(abs(Double(amount) / maxBalance) * maxBarWidth), 80), height: 25)
                                            .overlay(
                                                Text("\(String(format: "%.2f", amount)) €")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                            )
                                            .padding(.horizontal, 5) // Add horizontal padding for better spacing
                                    }
                                    if let amount = balance.balance, amount > 0 {
                                        Spacer()
                                        Rectangle()
                                            .fill(Color.green.opacity(0.8)) // Set opacity here
                                            .cornerRadius(5) // Set corner radius here
                                            .frame(width: max(CGFloat((amount) / Float(maxBalance)) * maxBarWidth, 80), height: 25)
                                            .overlay(
                                                Text("\(String(format: "%.2f", amount)) €")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                            )
                                            .padding(.horizontal, 5) // Add horizontal padding for better spacing
                                    }
                                }
                            }
                        }
                    }
                    .refreshable {
                        fetchBalances()
                    }
                }
            }
        }
        .onAppear {
            fetchBalances()
        }
    }

    private var maxBalance: Double {
        return balances.map { abs(Double($0.balance ?? 0)) }.max() ?? 1
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
