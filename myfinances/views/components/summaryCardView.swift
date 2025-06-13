import SwiftUI

struct SummaryCardView: View {
    let summaryItem: SummaryItem
    let selectedCurrency: CurrencyType
    let currencyConverter: CurrencyConverter // Add this parameter
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            HStack(spacing: 12) {
                Image(systemName: Icon.categoryIcon(for: summaryItem.type))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.categoryColor(for: summaryItem.type))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(summaryItem.type.capitalized)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 8) {
                        Text("\(summaryItem.numberOfItems) items")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                        
                        Text("\(String(format: "%.1f", summaryItem.pct))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(CurrencyConverter.formatAmount(currencyConverter.convertAmount(summaryItem.totalAmount, to: selectedCurrency), currency: selectedCurrency.symbol))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Total")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .padding(16)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }
            
            // Expandable details
            if isExpanded {
                ExpandedSummaryView(summaryItem: summaryItem, selectedCurrency: selectedCurrency, currencyConverter: currencyConverter)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

struct ExpandedSummaryView: View {
    let summaryItem: SummaryItem
    let selectedCurrency: CurrencyType
    let currencyConverter: CurrencyConverter // Add this parameter
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    // Monthly Average
                    VStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .foregroundColor(.green)
                            .frame(width: 24, height: 24)
                        
                        VStack(spacing: 2) {
                            Text(CurrencyConverter.formatAmount(currencyConverter.convertAmount(summaryItem.amountPerMonth, to: selectedCurrency), currency: selectedCurrency.symbol))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Monthly Average")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Percentage
                    VStack(spacing: 8) {
                        Image(systemName: "chart.pie")
                            .font(.title3)
                            .foregroundColor(.orange)
                            .frame(width: 24, height: 24)
                        
                        VStack(spacing: 2) {
                            Text("\(String(format: "%.1f", summaryItem.pct))%")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Percentage")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Total Items
                    VStack(spacing: 8) {
                        Image(systemName: "number")
                            .font(.title3)
                            .foregroundColor(.purple)
                            .frame(width: 24, height: 24)
                        
                        VStack(spacing: 2) {
                            Text("\(summaryItem.numberOfItems)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Total Items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Average per Item
                    VStack(spacing: 8) {
                        Image(systemName: "divide")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        VStack(spacing: 2) {
                            Text(CurrencyConverter.formatAmount(currencyConverter.convertAmount(summaryItem.totalAmount / Double(summaryItem.numberOfItems), to: selectedCurrency), currency: selectedCurrency.symbol))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Avg per Item")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            .padding(16)
        }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .top)),
            removal: .opacity.combined(with: .move(edge: .top))
        ))
    }
}
