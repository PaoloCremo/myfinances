import Foundation

struct SummaryResponse: Codable {
    let summary: [SummaryItem]
}

struct SummaryItem: Codable, Identifiable {
    let id = UUID()
    let type: String
    let totalAmount: Double
    let amountPerMonth: Double
    let pct: Double
    let numberOfItems: Int
    
    enum CodingKeys: String, CodingKey {
        case type
        case totalAmount = "tot"
        case amountPerMonth = "totpmth"
        case pct
        case numberOfItems = "n_items"
    }
}
