import Foundation

struct Balance: Codable, Identifiable {
    var id: String { username }
    let username: String
    let amount: Double
}

struct BalancesResponse: Codable {
    let balances: [String: Double]
}
