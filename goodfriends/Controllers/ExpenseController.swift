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
    
    func fetchExpense(groupId: String, expenseId: String, completion: @escaping (Result<FetchedExpense, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "\(API.baseURL)/v1/expenses/\(groupId)/\(expenseId)") else {
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
                let expenseResponse = try decoder.decode(ExpenseResponse.self, from: data)
                let expense = expenseResponse.expense
                completion(.success(expense))
                print(data)
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    func createExpense(with newExpense: [String: Any], completion: @escaping (Result<Expense, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "\(API.baseURL)/v1/expenses") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL or token"])))
            return
        }

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
    
    func updateExpense(expenseId: String, with updatedExpense: [String: Any], completion: @escaping (Result<Expense, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "\(API.baseURL)/v1/expenses/\(expenseId)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL or token"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: updatedExpense, options: [])
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

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
                let updatedExpense = try decoder.decode(Expense.self, from: data)
                completion(.success(updatedExpense))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func deleteExpense(expenseId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "\(API.baseURL)/v1/expenses/\(expenseId)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL or token"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(token, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            if [200, 204].contains(httpResponse.statusCode) {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to delete expense"])))
            }
        }.resume()
    }
}
