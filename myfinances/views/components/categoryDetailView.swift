//
//  categoryDetailView.swift
//  myfinances
//
//  Created by Paolo Cremonese on 2025-06-12.
//

import SwiftUI

struct CategoryDetailView: View {
    let summaryItem: SummaryItem
    let selectedCurrency: CurrencyType
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    private let networkManager = NetworkManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: Icon.categoryIcon(for: summaryItem.type))
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                        .background(Color.categoryColor(for: summaryItem.type))
                        .clipShape(Circle())
                    
                    Text(summaryItem.type.capitalized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(summaryItem.numberOfItems) transactions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Stats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    DetailStatView(
                        title: "Total Amount",
                        value: CurrencyFormatter.formatAmount(summaryItem.totalAmount, currency: selectedCurrency.symbol),
                        icon: "dollarsign.circle",
                        color: .green
                    )
                    
                    DetailStatView(
                        title: "Monthly Average",
                        value: CurrencyFormatter.formatAmount(summaryItem.amountPerMonth, currency: selectedCurrency.symbol),
                        icon: "calendar",
                        color: .blue
                    )
                    
                    DetailStatView(
                        title: "Percentage",
                        value: "\(String(format: "%.1f", summaryItem.pct))%",
                        icon: "chart.pie",
                        color: .orange
                    )
                    
                    DetailStatView(
                        title: "Average per Item",
                        value: CurrencyFormatter.formatAmount(summaryItem.totalAmount / Double(summaryItem.numberOfItems), currency: selectedCurrency.symbol),
                        icon: "divide.circle",
                        color: .purple
                    )
                }
                
//                 Spacer() // this "crashes" the expandable view

                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        LoadingView()
                    } else if let error = viewModel.errorMessage {
                        ErrorView(message: error)
                    } else {
                        ExpenseListView(viewModel: viewModel, 
                                        data: .expensesByType(viewModel.expensesByType),
                                        type: summaryItem.type)
                    }
                    
                }.onAppear {
                    viewModel.loadExpensesByType(type: summaryItem.type)
                }
            }
            .padding()
            .navigationTitle("Category Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailStatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
