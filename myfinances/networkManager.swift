import Foundation

class NetworkManager {
    private let host = fastAPIConfig.baseURL
    private let session = URLSession.shared
    
    // Initialize and fetch token automatically
        init() {
            Task {
                do {
                    try await AuthManager.shared.login()
                } catch {
                    print("Failed to login: \(error)")
                }
            }
        }

    func fetchExpenses() async throws -> [Expense] {
        try await performRequest(
            path: "/expenses",
            responseType: ExpenseResponse.self
        ).expenses
    }

     func fetchExpensesByType(type: String) async throws -> [Expense] {
        try await performRequest(
            path: "/expenses/\(type)",
            responseType: ExpenseResponse.self
        ).expenses
    }
    
    func fetchSummary() async throws -> [SummaryItem] {
        try await performRequest(
            path: "/expenses_summary",
            responseType: SummaryResponse.self
        ).summary
    }
    
    func fetchIncome() async throws -> [Income] {
        try await performRequest(
            path: "/income",
            responseType: IncomeResponse.self
        ).income
    }

    
    private func performRequest<T: Decodable>(
        path: String,
        responseType: T.Type
    ) async throws -> T {
        let token = try await AuthManager.shared.validAccessToken()
        let url = URL(string: "https://\(host)\(path)")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await session.data(for: request)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            if (error as? URLError)?.code == .badServerResponse {
                return try await performRequest(path: path, responseType: responseType)
            }
            throw error
        }
    }

}
