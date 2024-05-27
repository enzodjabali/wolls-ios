import Foundation

class RefundController {
    static let shared = RefundController()
    
    func fetchRefunds(groupId: String, completion: @escaping (Result<[RefundSimplified], Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "\(API.baseURL)/v1/refunds/\(groupId)?simplified=true") else {
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

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            do {
                let refunds = try decoder.decode([RefundSimplified].self, from: data)
                completion(.success(refunds))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchDetailedRefunds(groupId: String, completion: @escaping (Result<[RefundDetailed], Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "\(API.baseURL)/v1/refunds/\(groupId)?simplified=false") else {
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

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            do {
                let refunds = try decoder.decode([RefundDetailed].self, from: data)
                completion(.success(refunds))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
