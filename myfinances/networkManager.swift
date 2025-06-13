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

    func fetchIncome() async throws -> [Income] {
        guard let url = URL(string: "https://\(host)/income") else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
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

