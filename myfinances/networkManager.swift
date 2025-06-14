import Foundation

class NetworkManager {
    private let host = fastAPIConfig.baseURL
    private let session = URLSession.shared
    private var token: String?
    private let username = fastAPIConfig.username
    private let password = fastAPIConfig.password
    
    // Initialize and fetch token automatically
    init() {
        Task {
            do {
                try await self.login()
            } catch {
                print("Failed to login: \(error)")
            }
        }
    }
    
    // Login and store token
    func login() async throws {
        let url = URL(string: "https://\(host)/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "username=\(username)&password=\(password)"
        request.httpBody = body.data(using: .utf8)
        
        let (data, _) = try await session.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let token = json?["access_token"] as? String else {
            throw NetworkError.decodingFailed
        }
        self.token = token
    }
    
    func fetchExpenses() async throws -> [Expense] {
        let url = URL(string: "https://\(host)/expenses")!
        var request = URLRequest(url: url)
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, _) = try await session.data(for: request)
        let result = try JSONDecoder().decode(ExpenseResponse.self, from: data)
        return result.expenses
    }
    
    func fetchSummary() async throws -> [SummaryItem] {
        let url = URL(string: "https://\(host)/expenses/summary")!
        var request = URLRequest(url: url)
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, _) = try await session.data(for: request)
        let result = try JSONDecoder().decode(SummaryResponse.self, from: data)
        return result.summary
    }

    func fetchIncome() async throws -> [Income] {
        guard let url = URL(string: "https://\(host)/income") else {
            throw NetworkError.invalidURL
        }
        
        do {
            var request = URLRequest(url: url)
            if let token = token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("Server error: \(httpResponse.statusCode)")
                }
            }
            
            let result = try JSONDecoder().decode(IncomeResponse.self, from: data)
            return result.income
        } catch {
            print("Network error: \(error)")
            throw error
        }
    }

}

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case noData
    case decodingFailed
    case unknown
}

