//
//  currencyFormatter.swift
//  myfinances
//
//  Created by Paolo Cremonese on 2025-06-12.
//

import Foundation
import SwiftUI

struct CurrencyFormatter {
    static func formatAmount(_ amount: Double?, currency: String) -> String {
        guard let amount = amount else { return "\(currency)0.00" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currency)0.00"
    }
    
    static func amountColor(_ amount: Double?) -> Color {
        guard let amount = amount else { return .primary }
        return amount >= 0 ? .green : .primary
    }
}
