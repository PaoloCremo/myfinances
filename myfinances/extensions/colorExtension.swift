import SwiftUI

extension Color {
    static func categoryColor(for type: String) -> Color {
        let lowercased = type.lowercased().trimmingCharacters(in: .whitespaces)
        switch lowercased {
        case let category where category.contains("rent") || category.contains("education") || category.contains("forex") || category.contains("withdraw"):
            return .red
        case let category where category.contains("investments") || category.contains("entertainment") || category.contains("prestito") || category.contains("internal"):
            return .orange
        case let category where category.contains("out") || category.contains("electricity") || category.contains("taxes") || category.contains("rimborsi"):
            return .yellow
        case let category where category.contains("grocery") || category.contains("fees") || category.contains("culture") || category.contains("earnings"):
            return .green
        case let category where category.contains("flights") || category.contains("sport") || category.contains("tbd"):
            return .mint
        case let category where category.contains("trips") || category.contains("gifts") || category.contains("barber") || category.contains("electric"):
            return .cyan
        case let category where category.contains("hotels") || category.contains("home") || category.contains("parking"):
            return .blue
        case let category where category.contains("health") || category.contains("technology") || category.contains("cuttleries"):
            return .purple
        case let category where category.contains("phone") || category.contains("clothes") || category.contains("cash"):
            return .pink
        case let category where category.contains("gas") || category.contains("other"):
            return .black
        default:
            return .gray
        }
    }
}
