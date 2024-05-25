import Foundation

class ExpenseController {
    static let shared = ExpenseController()
    
    func fetchExpenses(groupId: String, completion: @escaping (Result<[Expense], Error>) -> Void) {
            guard let token = UserDefaults.standard.string(forKey: "userToken"),
                  let url = URL(string: "\(API.baseURL)/v1/expenses/\(groupId)") else {
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
                    let expenses = try decoder.decode([Expense].self, from: data)
                    completion(.success(expenses))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }

    func createExpense(groupId: String, title: String, amount: Double, category: String, refundRecipients: [String], completion: @escaping (Result<Expense, Error>) -> Void) {
            guard let token = UserDefaults.standard.string(forKey: "userToken"),
                  let url = URL(string: "\(API.baseURL)/v1/expenses") else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL or token"])))
                return
            }

            let newExpense: [String: Any] = [
                "title": title,
                "amount": amount,
                "group_id": groupId,
                "category": category,
                "refund_recipients": refundRecipients
            ]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: newExpense, options: []) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body"])))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(token, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                    do {
                        print("Raw response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                        let newExpense = try JSONDecoder().decode(Expense.self, from: data)
                        completion(.success(newExpense))
                    } catch {
                        print("Decoding error: \(error)")
                        completion(.failure(error))
                    }
                } else {
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = jsonResponse["error"] as? String {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create expense"])))
                    }
                }
            }.resume()
        }
}
