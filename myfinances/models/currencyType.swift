import Foundation

enum CurrencyType: String, CaseIterable, Identifiable {
    case eur = "EUR"
    case usd = "USD"
    case cad = "CAD"
    case pln = "PLN"
    case other = "OTHER"
    
    var id: String { rawValue }
    var code: String { rawValue }
    
    var symbol: String {
        switch self {
        case .eur: return "€"
        case .usd: return "$"
        case .cad: return "CA$"
        case .pln: return "zł"
        case .other: return "¤"
        }
    }
    
    var name: String {
        switch self {
        case .eur: return "Euro"
        case .usd: return "US Dollar"
        case .cad: return "Canadian Dollar"
        case .pln: return "Polish Złoty"
        case .other: return "Other Currency"
        }
    }
    
    var flag: String {
        switch self {
        case .eur: return "🇪🇺"
        case .usd: return "🇺🇸"
        case .cad: return "🇨🇦"
        case .pln: return "🇵🇱"
        case .other: return "🌍"
        }
    }
    
    func getValue(from expense: Expense) -> Double? {
        switch self {
        case .eur: return expense.eur
        case .usd: return expense.usd
        case .cad: return expense.cad
        case .pln: return expense.pln
        case .other: return expense.other
        }
    }
}

enum ContentViewType {
    case text
    case plot
    case summary
}
