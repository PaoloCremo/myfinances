import Foundation

struct Icon {
    static func categoryIcon(for type: String) -> String {
        let category = type.lowercased()
        switch category {
        case _ where category.contains("rent"):
            return "house.fill"
        case _ where category.contains("education"):
            return "book.fill"
        case _ where category.contains("forex"):
            return "dollarsign.circle.fill"
        case _ where category.contains("withdraw"):
            return "arrow.down.circle.fill"
        case _ where category.contains("investments"):
            return "chart.line.uptrend.xyaxis"
        case _ where category.contains("entertainment"):
            return "tv.fill"
        case _ where category.contains("prestito"):
            return "banknote.fill"
        case _ where category.contains("internal"):
            return "arrow.right.arrow.left"
        case _ where category.contains("out"):
            return "wineglass.fill"
        case _ where category.contains("electricity"):
            return "bolt.fill"
        case _ where category.contains("taxes"):
            return "doc.text.fill"
        case _ where category.contains("rimborsi"):
            return "arrow.2.circlepath.circle.fill"
        case _ where category.contains("grocery"):
            return "cart.fill"
        case _ where category.contains("fees"):
            return "creditcard.fill"
        case _ where category.contains("culture"):
            return "theatermasks.fill"
        case _ where category.contains("earnings"):
            return "banknote.fill"
        case _ where category.contains("flights"):
            return "airplane"
        case _ where category.contains("sport"):
            return "figure.run"
        case _ where category.contains("tbd"):
            return "questionmark.circle.fill"
        case _ where category.contains("trips"):
            return "suitcase.fill"
        case _ where category.contains("gifts"):
            return "gift.fill"
        case _ where category.contains("barber"):
            return "scissors"
        case _ where category.contains("hotels"):
            return "bed.double.fill"
        case _ where category.contains("home"):
            return "house.fill"
        case _ where category.contains("parking"):
            return "parkingsign.circle.fill"
        case _ where category.contains("health"):
            return "cross.fill"
        case _ where category.contains("technology"):
            return "cpu"
        case _ where category.contains("cuttleries"):
            return "fork.knife"
        case _ where category.contains("phone"):
            return "phone.fill"
        case _ where category.contains("clothes"):
            return "tshirt.fill"
        case _ where category.contains("cash"):
            return "banknote.fill"
        case _ where category.contains("gas"):
            return "fuelpump"
        case _ where category.contains("other"):
            return "ellipsis.circle"
        default:
            return "questionmark"
        }
    }
}
