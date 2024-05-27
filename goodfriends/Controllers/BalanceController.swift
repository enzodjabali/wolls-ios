import Foundation

class BalanceController {
    static let shared = BalanceController()
    
    func fetchBalances(groupId: String, completion: @escaping (Result<[Balance], Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "\(API.baseURL)/v1/balances/\(groupId)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL or token"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let balancesResponse = try JSONDecoder().decode(BalancesResponse.self, from: data)
                let balances = balancesResponse.balances.map { Balance(username: $0.key, amount: $0.value) }
                completion(.success(balances))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
