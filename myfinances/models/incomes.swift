import Foundation

struct IncomeResponse: Codable {
    let columns: [String]
    let income: [Income]
}

struct Income: Codable, Identifiable {
    let id = UUID()
    let date: String
    let type: String
    let descriptionText: String
    let eur: Double?
    let usd: Double?
    let cad: Double?
    let pln: Double?
    let other: Double?
    let daily_total: Double?
    let bank: String?
    
    enum CodingKeys: String, CodingKey {
        case date, type, eur, usd, cad, pln, other, daily_total, bank
        case descriptionText = "description"
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        date = try container.decode(String.self)
        type = try container.decode(String.self)
        descriptionText = try container.decode(String.self)
        eur = try container.decodeIfPresent(Double.self)
        usd = try container.decodeIfPresent(Double.self)
        cad = try container.decodeIfPresent(Double.self)
        pln = try container.decodeIfPresent(Double.self)
        other = try container.decodeIfPresent(Double.self)
        daily_total = try container.decodeIfPresent(Double.self)
        bank = try container.decodeIfPresent(String.self)
    }
}
