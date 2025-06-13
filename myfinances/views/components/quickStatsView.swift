//
//  quickStatsView.swift
//  myfinances
//
//  Created by Paolo Cremonese on 2025-06-12.
//

import SwiftUI

struct QuickStatsView: View {
    let summaryData: [SummaryItem]
    let selectedCurrency: CurrencyType
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Quick Stats")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                StatItemView(
                    title: "Total Categories",
                    value: "\(summaryData.count)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                StatItemView(
                    title: "Total Items",
                    value: "\(summaryData.reduce(0) { $0 + $1.numberOfItems })",
                    icon: "number",
                    color: .green
                )
                
                StatItemView(
                    title: "Avg per Category",
                    value: CurrencyFormatter.formatAmount(summaryData.reduce(0) { $0 + $1.totalAmount } / Double(summaryData.count), currency: selectedCurrency.symbol),
                    icon: "chart.bar",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatItemView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
