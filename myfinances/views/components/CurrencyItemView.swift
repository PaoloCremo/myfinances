//
//  CurrencyItemView.swift
//  myfinances
//
//  Created by Paolo Cremonese on 2025-06-12.
//

import SwiftUI

struct CurrencyItemView: View {
    let currency: CurrencyType
    let amount: Double?
    let isPrimary: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Text(currency.flag)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(currency.code)
                    .font(.caption)
                    .fontWeight(isPrimary ? .semibold : .medium)
                    .foregroundColor(isPrimary ? .blue : .primary)
                
                if let amount = amount {
                    Text(CurrencyFormatter.formatAmount(amount, currency: currency.symbol))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    Text("N/A")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isPrimary {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isPrimary ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(6)
    }
}
