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
    
    @State private var showStickyHeader = false
    
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
                        .id("title")
                    
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
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: ViewOffsetKey.self,
                    value: -geometry.frame(in: .named("scroll")).minY
                )
            })
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ViewOffsetKey.self) { offset in
            withAnimation {
                // Show sticky header when scrolled down 150 points
                showStickyHeader = offset > 150
            }
        }
        .overlay(
            Group {
                if showStickyHeader {
                    VStack {
                        HStack {
                            Spacer()

                            Text("\(summaryItem.type.capitalized) ")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Image(systemName: Icon.categoryIcon(for: summaryItem.type))
                                .background(Color.categoryColor(for: summaryItem.type))
                                // .clipShape(Circle())
                                .font(.title2)
                                .foregroundColor(.white)
                                // .padding(.leading, 8)

                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(.white)
                        .transition(.move(edge: .top))
                    }
                }
            },
            alignment: .top
        )
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

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
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
