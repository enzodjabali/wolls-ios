import SwiftUI

struct BalancesView: View {
    let groupId: String
    @State private var balances: [UserStatus] = []
    @State private var fetchError: String?
    @State private var isLoading: Bool = true
    
    @State private var selectedUserId: String?
    @State private var selectedUser: User?
    @State private var showUserDetail = false
    @State private var userStatuses: [UserStatus] = []

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
                            Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
                            VStack {
                                Text("No balances to display.")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
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
                                            .fill(Color.red.opacity(0.8))
                                            .cornerRadius(5)
                                            .frame(width: max(CGFloat(abs(Double(amount) / maxBalance) * maxBarWidth), 80), height: 25)
                                            .overlay(
                                                Text("\(String(format: "%.2f", amount)) €")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                            )
                                            .padding(.horizontal, 5)
                                    }
                                    if let amount = balance.balance, amount > 0 {
                                        Spacer()
                                        Rectangle()
                                            .fill(Color.green.opacity(0.8))
                                            .cornerRadius(5)
                                            .frame(width: max(CGFloat((amount) / Float(maxBalance)) * maxBarWidth, 80), height: 25)
                                            .overlay(
                                                Text("\(String(format: "%.2f", amount)) €")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                            )
                                            .padding(.horizontal, 5)
                                    }
                                }
                            }
                            .onTapGesture {
                                selectedUserId = balance.id
                                showUserDetail = true
                                fetchUserDetails(userId: balance.id)
                            }
                        }
                    }
                    .refreshable {
                        fetchBalances()
                    }
                }
            }
        }
        .sheet(isPresented: $showUserDetail) {
            if let selectedUser = selectedUser {
                UserDetailView(user: selectedUser, groupId: groupId, userStatuses: $userStatuses)
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
        return UIScreen.main.bounds.width * 0.4
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

    private func fetchUserDetails(userId: String) {
        UserController.shared.fetchUserDetails(userId: userId, groupId: groupId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.selectedUser = user
                case .failure(let error):
                    self.fetchError = error.localizedDescription
                }
            }
        }
    }
}
