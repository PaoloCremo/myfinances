import SwiftUI

struct IncomeCardView: View {
    let income: Income
    let selectedCurrency: CurrencyType
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            HStack(spacing: 12) {
                // Category icon
                Image(systemName: Icon.categoryIcon(for: income.type))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.categoryColor(for: income.type))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(income.descriptionText)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(isExpanded ? nil : 2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 8) {
                        Text(income.type)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.categoryColor(for: income.type).opacity(0.2))
                            .foregroundColor(Color.categoryColor(for: income.type))
                            .cornerRadius(4)
                        
                        Text(DateFormatter.formatExpenseDate(income.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(CurrencyConverter.formatAmount(selectedCurrency.getValue(from: income), currency: selectedCurrency.symbol))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(CurrencyConverter.amountColorIn(selectedCurrency.getValue(from: income)))
                    
                    Text(selectedCurrency.code)
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(3)
                    
                    if let bank = income.bank, !bank.isEmpty {
                        Text(bank)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(Color(.systemGray5))
                            .cornerRadius(3)
                    }
                }
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            .padding(16)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }
            
            // Expandable currency details
            if isExpanded {
                ExpandedCurrencyView2(income: income, selectedCurrency: selectedCurrency)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

struct ExpandedCurrencyView2: View {
    let income: Income
    let selectedCurrency: CurrencyType
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(currencyData, id: \.currency.code) { data in
                        CurrencyItemView(
                            currency: data.currency,
                            amount: data.amount,
                            isPrimary: data.currency == selectedCurrency
                        )
                    }
                }
                
                if let dailyTotal = income.daily_total {
                    HStack {
                        Text("Daily Total:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(CurrencyConverter.formatAmount(dailyTotal, currency: "€"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 4)
                }
            }
            .padding(16)
        }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .top)),
            removal: .opacity.combined(with: .move(edge: .top))
        ))
    }
    
    private var currencyData: [(currency: CurrencyType, amount: Double?)] {
        CurrencyType.allCases.compactMap { currencyType in
            let amount = currencyType.getValue(from: income)
            return (amount != nil && amount != 0) ? (currencyType, amount) : nil
        }
    }
}
