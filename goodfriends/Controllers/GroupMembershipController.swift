import Foundation

class GroupMembershipController: ObservableObject {
    static let shared = GroupMembershipController()
    
    func fetchInvitationCount(completion: @escaping (Result<Int, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "\(API.baseURL)/v1/groups/memberships/invitations/count") else {
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

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let count = jsonResponse["invitationCount"] as? Int {
                    completion(.success(count))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse invitation count"])))
                }
            } else {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorMessage = jsonResponse["error"] as? String {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch invitation count"])))
                }
            }
        }.resume()
    }
    
    func fetchInvitations(completion: @escaping (Result<[Group], Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "\(API.baseURL)/v1/groups/memberships/invitations") else {
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

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    let groups = try JSONDecoder().decode([Group].self, from: data)
                    completion(.success(groups))
                } catch {
                    completion(.failure(error))
                }
            } else {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorMessage = jsonResponse["error"] as? String {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch invitations"])))
                }
            }
        }.resume()
    }
        
    func respondToInvitation(groupId: String, accept: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken"),
              let url = URL(string: "\(API.baseURL)/v1/groups/memberships/invitations") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL or token"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "group_id": groupId,
            "accept_invitation": accept
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
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

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to respond to invitation"])))
                return
            }

            if httpResponse.statusCode == 200 {
                completion(.success(()))
            } else {
                if let data = data,
                   let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorMessage = jsonResponse["error"] as? String {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to respond to invitation"])))
                }
            }
        }.resume()
    }
}
