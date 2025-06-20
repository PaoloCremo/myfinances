import SwiftUI

protocol ExpenseProtocol {
    var date: String { get }
    var type: String { get }
    var descriptionText: String { get }
    var eur: Double? { get }
    var usd: Double? { get }
    var cad: Double? { get }
    var pln: Double? { get }
    var other: Double? { get }
    var daily_total: Double? { get }
    var bank: String? { get }
}

enum ExpenseListData {
    case expenses([Expense])
    case expensesByType([Expense])
}

struct ExpenseCardView: View {
    let expense: any ExpenseProtocol
    let selectedCurrency: CurrencyType
    @State private var isExpanded = false
    
    /*
    init(expenseData: ExpenseListData, selectedCurrency: CurrencyType) {
        switch expenseData {
        case .expenses(let expenses):
            self.expense = expenses // .first ?? expenses[0]
        case .expensesByType(let expensesByType):
            self.expense = expensesByType // .first ?? expensesByType[0]
        }
        self.selectedCurrency = selectedCurrency
    }
     */
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            HStack(spacing: 12) {
                // Category icon
                Image(systemName: Icon.categoryIcon(for: expense.type))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.categoryColor(for: expense.type))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.descriptionText)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(isExpanded ? nil : 2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 8) {
                        Text(expense.type)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.categoryColor(for: expense.type).opacity(0.2))
                            .foregroundColor(Color.categoryColor(for: expense.type))
                            .cornerRadius(4)
                        
                        Text(DateFormatter.formatExpenseDate(expense.date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(CurrencyConverter.formatAmount(selectedCurrency.getValue(from: expense), currency: selectedCurrency.symbol))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(CurrencyConverter.amountColorExp(selectedCurrency.getValue(from: expense)))
                    
                    Text(selectedCurrency.code)
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(3)
                    
                    if let bank = expense.bank, !bank.isEmpty {
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
                ExpandedCurrencyView(expense: expense, selectedCurrency: selectedCurrency)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

struct ExpandedCurrencyView: View {
    let expense: any ExpenseProtocol
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
                
                if let dailyTotal = expense.daily_total {
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
            let amount = currencyType.getValue(from: expense)
            return (amount != nil && amount != 0) ? (currencyType, amount) : nil
        }
    }
}
