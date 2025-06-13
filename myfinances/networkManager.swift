import Foundation

class NetworkManager {
    private let host = fastAPIConfig.baseURL
    private let session = URLSession.shared
    
    func fetchExpenses() async throws -> [Expense] {
        let url = URL(string: "https://\(host)/expenses")!
        let (data, _) = try await session.data(from: url)
        let result = try JSONDecoder().decode(ExpenseResponse.self, from: data)
        return result.expenses
    }
    
    func fetchSummary() async throws -> [SummaryItem] {
        let url = URL(string: "https://\(host)/expenses/summary")!
        let (data, _) = try await session.data(from: url)
        let result = try JSONDecoder().decode(SummaryResponse.self, from: data)
        return result.summary
    }
}
