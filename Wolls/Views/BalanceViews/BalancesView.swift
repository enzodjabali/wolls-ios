import SwiftUI

struct BalancesView: View {
    let groupId: String
    @State private var users: [UserStatus] = []
    @State private var fetchError: String?
    @State private var isLoading: Bool = true
    
    @State private var selectedUserId: String?
    @State private var selectedUser: User?
    @State private var showUserDetail = false
    @State private var showAlertForNonMember = false
    @State private var nonMemberPseudonym: String?

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
                if users.isEmpty {
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
                        ForEach(users.indices, id: \.self) { index in
                            let user = users[index]
                            VStack(alignment: .leading) {
                                if let amount = user.balance, amount < 0 {
                                    Text(user.pseudonym)
                                        .font(.headline)
                                } else {
                                    HStack {
                                        Spacer()
                                        Text(user.pseudonym)
                                            .font(.headline)
                                    }
                                }

                                HStack {
                                    if let amount = user.balance, amount < 0 {
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
                                    if let amount = user.balance, amount > 0 {
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
                                if user.hasAcceptedInvitation {
                                    selectedUserId = user.id
                                    showUserDetail = true
                                    fetchUserDetails(userId: user.id)
                                } else {
                                    self.nonMemberPseudonym = user.pseudonym
                                    self.showAlertForNonMember = true
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
        .sheet(isPresented: $showUserDetail) {
            if let selectedUser = selectedUser {
                UserDetailView(user: selectedUser, groupId: groupId, userStatuses: $users)
            }
        }
        .alert(isPresented: $showAlertForNonMember) {
            Alert(
                title: Text("User Not a Member"),
                message: Text("\(nonMemberPseudonym ?? "This user") is not a member of the group anymore."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            fetchBalances()
        }
    }

    private var maxBalance: Double {
        return users.map { abs(Double($0.balance ?? 0)) }.max() ?? 1
    }

    private var maxBarWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.4
    }

    private func fetchBalances() {
        BalanceController.shared.fetchBalances(groupId: groupId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let balances):
                    self.users = balances
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
