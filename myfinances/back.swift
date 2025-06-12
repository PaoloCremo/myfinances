//
// myfinancesApp.swift
// myfinances
//
// Created by Paolo Cremonese on 2025-06-11.
//

import SwiftUI
import Charts

struct ExpenseAppView: View {
    @State private var displayText = "Click a button to load data"
    @State private var headerText = ""
    @State private var currentView: ContentViewType = .text
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var summaryData: [SummaryItem] = []
    @State private var expenses: [Expense] = []
    @State private var selectedCurrency: CurrencyType = .cad
    @State private var showingCurrencyPicker = false
    @State private var pressLocation: CGPoint?
    
    let host = "fastapi.paolocremonese.com"
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with currency selector
            HStack {
                Text("My Finances")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Currency selector button
                Button(action: {
                    showingCurrencyPicker = true
                }) {
                    HStack(spacing: 4) {
                        Text(selectedCurrency.symbol)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(selectedCurrency.code)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Button layout
            HStack(spacing: 20) {
                ActionButton(title: "Load Expenses") {
                    loadExpenses()
                }
                
                ActionButton(title: "Show Summary") {
                    showSummary()
                }
                
                ActionButton(title: "Show Plot") {
                    showPlot()
                }
                
                ActionButton(title: "Clear") {
                    clearDisplay()
                }
            }
            .padding()
            .frame(height: 60)
            
            // Content area
            Group {
                if isLoading {
                    VStack(spacing: 12) {
                        ForEach(0..<5, id: \.self) { _ in
                            ExpenseSkeletonView()
                        }
                    }
                    .padding()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    switch currentView {
                    case .text:
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(expenses) { expense in
                                    ExpenseCardView(
                                        expense: expense,
                                        selectedCurrency: selectedCurrency
                                    )
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            loadExpenses()
                        }
                        
                    case .summary: // Add this new case
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(summaryData) { summaryItem in
                                    SummaryCardView(
                                        summaryItem: summaryItem,
                                        selectedCurrency: selectedCurrency
                                    )
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            showSummary()
                        }
                        
                    case .plot:
                        VStack(spacing: 16) {
                            // Chart title
                            Text("Expense Summary by Category")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.top)
                            
                            InteractiveChartView(
                                summaryData: summaryData,
                                selectedCurrency: selectedCurrency
                            )
                        }
                        .padding()

                    }
                }
            }

            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6))
        }
        .sheet(isPresented: $showingCurrencyPicker) {
            CurrencyPickerView(selectedCurrency: $selectedCurrency)
        }
    }
    
    private func loadExpenses() {
        isLoading = true
        errorMessage = nil
        let url = URL(string: "https://\(host)/expenses")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { 
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error loading expenses: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received"
                }
                return
            }
            
            do {
                let result: ExpenseResponse = try JSONDecoder().decode(ExpenseResponse.self, from: data)
                DispatchQueue.main.async {
                    expenses = Array(result.expenses.prefix(100))
                    currentView = .text
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Error parsing data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private func showSummary() {
         isLoading = true
         errorMessage = nil
         let url = URL(string: "https://\(host)/expenses/summary")!
         
         URLSession.shared.dataTask(with: url) { data, _, error in
             defer { 
                 DispatchQueue.main.async {
                     isLoading = false
                 }
             }
             
             if let error = error {
                 DispatchQueue.main.async {
                     errorMessage = "Error loading summary: \(error.localizedDescription)"
                 }
                 return
             }
             
             guard let data = data else {
                 DispatchQueue.main.async {
                     errorMessage = "No data received"
                 }
                 return
             }
             
             do {
                 let result = try JSONDecoder().decode(SummaryResponse.self, from: data)
                 DispatchQueue.main.async {
                     summaryData = result.summary
                     currentView = .summary // Change this to a new view type
                 }
             } catch {
                 DispatchQueue.main.async {
                     errorMessage = "Error parsing summary: \(error.localizedDescription)"
                 }
             }
         }.resume()
     }

    
    private func showPlot() {
        isLoading = true
        errorMessage = nil
        let url = URL(string: "https://\(host)/expenses/summary")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { 
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error loading plot data: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received"
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(SummaryResponse.self, from: data)
                DispatchQueue.main.async {
                    summaryData = result.summary
                    currentView = .plot
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Error parsing plot data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private func clearDisplay() {
        displayText = "Display cleared. Click a button to load data."
        headerText = ""
        expenses = []
        summaryData = []
        currentView = .text
    }
}

// MARK: - Currency Type Enum

enum CurrencyType: String, CaseIterable, Identifiable {
    case eur = "EUR"
    case usd = "USD"
    case cad = "CAD"
    case pln = "PLN"
    case other = "OTHER"
    
    var id: String { rawValue }
    
    var code: String { rawValue }
    
    var symbol: String {
        switch self {
        case .eur: return "€"
        case .usd: return "$"
        case .cad: return "CA$"
        case .pln: return "zł"
        case .other: return "¤"
        }
    }
    
    var name: String {
        switch self {
        case .eur: return "Euro"
        case .usd: return "US Dollar"
        case .cad: return "Canadian Dollar"
        case .pln: return "Polish Złoty"
        case .other: return "Other Currency"
        }
    }
    
    var flag: String {
        switch self {
        case .eur: return "🇪🇺"
        case .usd: return "🇺🇸"
        case .cad: return "🇨🇦"
        case .pln: return "🇵🇱"
        case .other: return "🌍"
        }
    }
    
    func getValue(from expense: Expense) -> Double? {
        switch self {
        case .eur: return expense.eur
        case .usd: return expense.usd
        case .cad: return expense.cad
        case .pln: return expense.pln
        case .other: return expense.other
        }
    }
}

// MARK: - Currency Picker View

struct CurrencyPickerView: View {
    @Binding var selectedCurrency: CurrencyType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(CurrencyType.allCases) { currency in
                Button(action: {
                    selectedCurrency = currency
                    dismiss()
                }) {
                    HStack(spacing: 12) {
                        Text(currency.flag)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currency.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("\(currency.code) • \(currency.symbol)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedCurrency == currency {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select Currency")
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

// MARK: - Modern UI Components

struct ExpenseCardView: View {
    let expense: Expense
    let selectedCurrency: CurrencyType
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content (always visible)
            HStack(spacing: 12) {
                // Category icon with colored background
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
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.categoryColor(for: expense.type).opacity(0.2))
                            .foregroundColor(Color.categoryColor(for: expense.type))
                            .cornerRadius(4)
                        
                        Text(formatDate(expense.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    // Show amount in selected currency
                    Text(formatAmount(selectedCurrency.getValue(from: expense), currency: selectedCurrency.symbol))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(amountColor(selectedCurrency.getValue(from: expense)))
                    
                    // Show selected currency code
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
                    
                    // Expand/Collapse indicator
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
            
            // Expandable currency details
            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 12) {
                        // Currency grid
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
                        
                        // Daily total if available
                        if let dailyTotal = expense.daily_total {
                            HStack {
                                Text("Daily Total:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(formatAmount(dailyTotal, currency: "€"))
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
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
    
    // Updated computed property to use CurrencyType
    private var currencyData: [(currency: CurrencyType, amount: Double?)] {
        CurrencyType.allCases.compactMap { currencyType in
            let amount = currencyType.getValue(from: expense)
            return (amount != nil && amount != 0) ? (currencyType, amount) : nil
        }
    }
    
    private func formatAmount(_ amount: Double?, currency: String) -> String {
        guard let amount = amount else { return "\(currency)0.00" }
        return String(format: "\(currency)%.2f", amount)
    }
    
    private func amountColor(_ amount: Double?) -> Color {
        guard let amount = amount else { return .primary }
        return amount >= 0 ? .green : .primary
    }
    
    private func formatDate(_ dateString: String) -> String {
        return dateString
    }
}

// MARK: - Updated Currency Item View

struct CurrencyItemView: View {
    let currency: CurrencyType
    let amount: Double?
    let isPrimary: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(currency.flag)
                        .font(.caption)
                    
                    Text(currency.code)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(isPrimary ? .blue : .secondary)
                }
                
                Text(formatAmount(amount, symbol: currency.symbol))
                    .font(.subheadline)
                    .fontWeight(isPrimary ? .semibold : .medium)
                    .foregroundColor(isPrimary ? .primary : .secondary)
            }
            
            Spacer()
            
            if isPrimary {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding(12)
        .background(isPrimary ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isPrimary ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
    
    private func formatAmount(_ amount: Double?, symbol: String) -> String {
        guard let amount = amount else { return "\(symbol)0.00" }
        return String(format: "\(symbol)%.2f", amount)
    }
}

struct ExpenseSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(.systemGray4))
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 6) {
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(height: 16)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 12)
                    .cornerRadius(3)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 60, height: 16)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 10)
                    .cornerRadius(3)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .opacity(isAnimating ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Helper Components

struct ActionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

// MARK: - Data Models

struct ExpenseResponse: Codable {
    let columns: [String]
    let expenses: [Expense]
}

struct Expense: Codable, CustomStringConvertible, Identifiable {
    let id = UUID()
    let date: String
    let type: String
    let descriptionText: String
    let eur: Double?
    let usd: Double?
    let cad: Double?
    let pln: Double?
    let other: Double?
    let daily_total: Double?
    let bank: String?
    
    enum CodingKeys: String, CodingKey {
        case date, type, eur, usd, cad, pln, other, daily_total, bank
        case descriptionText = "description"
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        date = try container.decode(String.self)
        type = try container.decode(String.self)
        descriptionText = try container.decode(String.self)
        eur = try container.decodeIfPresent(Double.self)
        usd = try container.decodeIfPresent(Double.self)
        cad = try container.decodeIfPresent(Double.self)
        pln = try container.decodeIfPresent(Double.self)
        other = try container.decodeIfPresent(Double.self)
        daily_total = try container.decodeIfPresent(Double.self)
        bank = try container.decodeIfPresent(String.self)
    }
    
    var description: String {
        return [
            date.padding(toLength: Self.columnWidths[0], withPad: " ", startingAt: 0),
            type.padding(toLength: Self.columnWidths[1], withPad: " ", startingAt: 0),
            descriptionText.padding(toLength: Self.columnWidths[2], withPad: " ", startingAt: 0),
            String(format: "%.2f€", eur ?? 0).padding(toLength: Self.columnWidths[3], withPad: " ", startingAt: 0),
            String(format: "%.2f$", usd ?? 0).padding(toLength: Self.columnWidths[4], withPad: " ", startingAt: 0),
            String(format: "%.2fCA$", cad ?? 0).padding(toLength: Self.columnWidths[5], withPad: " ", startingAt: 0),
            String(format: "%.2f", daily_total ?? 0).padding(toLength: Self.columnWidths[6], withPad: " ", startingAt: 0),
            (bank ?? "").padding(toLength: Self.columnWidths[7], withPad: " ", startingAt: 0)
        ].joined(separator: " | ")
    }
}

struct SummaryResponse: Codable {
    let summary: [SummaryItem]
}

struct SummaryItem: Codable, Identifiable, CustomStringConvertible {
    let id = UUID()
    let type: String
    let totalAmount: Double
    let amountPerMonth: Double
    let pct: Double
    let numberOfItems: Int
    
    enum CodingKeys: String, CodingKey {
        case type
        case totalAmount = "tot"
        case amountPerMonth = "totpmth"
        case pct
        case numberOfItems = "n_items"
    }
    
    var description: String {
        return [
            type.padding(toLength: Self.columnWidths[0], withPad: " ", startingAt: 0),
            String(format: "%.2f", totalAmount).padding(toLength: Self.columnWidths[1], withPad: " ", startingAt: 0),
            String(format: "%.2f", amountPerMonth).padding(toLength: Self.columnWidths[2], withPad: " ", startingAt: 0),
            String(format: "%.1f", pct).padding(toLength: Self.columnWidths[3], withPad: " ", startingAt: 0),
            String(numberOfItems).padding(toLength: Self.columnWidths[4], withPad: " ", startingAt: 0)
        ].joined(separator: " | ")
    }
}

// MARK: - Summary Card View

struct SummaryCardView: View {
    let summaryItem: SummaryItem
    let selectedCurrency: CurrencyType
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content (always visible)
            HStack(spacing: 12) {
                // Category icon with colored background
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
                    // Show total amount in selected currency
                    Text(formatAmount(convertAmount(summaryItem.totalAmount, to: selectedCurrency), currency: selectedCurrency.symbol))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Total")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // Expand/Collapse indicator
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
                VStack(spacing: 0) {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 16) {
                        // Summary statistics grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            SummaryStatView(
                                title: "Monthly Average",
                                value: formatAmount(convertAmount(summaryItem.amountPerMonth, to: selectedCurrency), currency: selectedCurrency.symbol),
                                icon: "calendar",
                                color: .green
                            )
                            
                            SummaryStatView(
                                title: "Percentage",
                                value: "\(String(format: "%.1f", summaryItem.pct))%",
                                icon: "chart.pie",
                                color: .orange
                            )
                            
                            SummaryStatView(
                                title: "Total Items",
                                value: "\(summaryItem.numberOfItems)",
                                icon: "number",
                                color: .purple
                            )
                            
                            SummaryStatView(
                                title: "Avg per Item",
                                value: formatAmount(convertAmount(summaryItem.totalAmount / Double(summaryItem.numberOfItems), to: selectedCurrency), currency: selectedCurrency.symbol),
                                icon: "divide",
                                color: .blue
                            )
                        }
                        
                        // Currency breakdown if needed
                        if selectedCurrency != .eur {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Currency Breakdown")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Original (EUR)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(formatAmount(summaryItem.totalAmount, currency: "€"))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(selectedCurrency.code)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(formatAmount(convertAmount(summaryItem.totalAmount, to: selectedCurrency), currency: selectedCurrency.symbol))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                }
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
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
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
    
    private func formatAmount(_ amount: Double?, currency: String) -> String {
        guard let amount = amount else { return "\(currency)0.00" }
        return String(format: "\(currency)%.2f", amount)
    }
    
    // Simple currency conversion (you might want to use real exchange rates)
    private func convertAmount(_ eurAmount: Double, to currency: CurrencyType) -> Double {
        switch currency {
        case .eur: return eurAmount
        case .usd: return eurAmount * 1.1 // Approximate conversion
        case .cad: return eurAmount * 1.5
        case .pln: return eurAmount * 4.3
        case .other: return eurAmount
        }
    }
}

// MARK: - Summary Stat View

struct SummaryStatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Interactive Chart View

struct InteractiveChartView: View {
    let summaryData: [SummaryItem]
    let selectedCurrency: CurrencyType
    @State private var selectedCategory: String? = nil
    @State private var showingDetail = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Interactive Chart
            ScrollView(.vertical, showsIndicators: true) {
                Chart(summaryData) { item in
                    BarMark(
                        x: .value("Percentage", item.pct),
                        y: .value("Category", item.type)
                    )
                    .foregroundStyle(Color.categoryColor(for: item.type))
                    .cornerRadius(4)
                }
                .frame(height: max(400, CGFloat(summaryData.count * 50)))
                .chartXAxisLabel("Percentage (%)")
                
                
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle().fill(Color.clear).contentShape(Rectangle())
                            .gesture(
                                LongPressGesture(minimumDuration: 0.12)
                                    .sequenced(before: DragGesture(minimumDistance: 0))
                                    .onEnded { value in
                                        switch value {
                                        case .second(true, let drag?):
                                            let location = drag.location
                                            let yValue: String? = proxy.value(atY: location.y, as: String.self)
//                                            print("Long pressed at y: \(location.y), value: \(yValue ?? "nil")")
                                            if let y = yValue {
                                                handleCategorySelection(category: y)
                                            }
                                        default:
                                            break
                                        }
                                    }
                            )
                    }
                }

                .chartYAxis {
                    AxisMarks(preset: .extended, position: .leading) { _ in
                        AxisValueLabel(horizontalSpacing: 15)
                            .font(.footnote)
                    }
                }
                .onChange(of: selectedCategory) { oldValue, newValue in
                    if let newValue = newValue {
                        handleCategorySelection(category: newValue)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: selectedCategory)
            }
            .frame(maxHeight: 400)
            
            // Quick stats below chart
            if !summaryData.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    QuickStatView(
                        title: "Categories",
                        value: "\(summaryData.count)",
                        icon: "list.bullet",
                        color: .blue
                    )
                    
                    QuickStatView(
                        title: "Total Items",
                        value: "\(summaryData.reduce(0) { $0 + $1.numberOfItems })",
                        icon: "number",
                        color: .green
                    )
                    
                    QuickStatView(
                        title: "Total Amount",
                        value: formatAmount(summaryData.reduce(0) { $0 + convertAmount($1.totalAmount, to: selectedCurrency) }, currency: selectedCurrency.symbol),
                        icon: "dollarsign.circle",
                        color: .orange
                    )
                }
            }
            
            // Tap instruction
            Text("Tap on a bar to see details")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .sheet(isPresented: $showingDetail) {
            if let selectedCategory = selectedCategory,
               let selectedItem = summaryData.first(where: { $0.type == selectedCategory }) {
                CategoryDetailView(
                    summaryItem: selectedItem,
                    selectedCurrency: selectedCurrency
                )
            }
        }
    }
    
    private func handleCategorySelection(category: String) {
        // print("Selected category from chart: \(category)")
        if let selectedItem = summaryData.first(where: { $0.type == category }) {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showingDetail = true
            }
        }
    }

    
    private func formatAmount(_ amount: Double?, currency: String) -> String {
        guard let amount = amount else { return "\(currency)0.00" }
        return String(format: "\(currency)%.0f", amount)
    }
    
    private func convertAmount(_ eurAmount: Double, to currency: CurrencyType) -> Double {
        switch currency {
        case .eur: return eurAmount
        case .usd: return eurAmount * 1.1
        case .cad: return eurAmount * 1.5
        case .pln: return eurAmount * 4.3
        case .other: return eurAmount
        }
    }
}


// MARK: - Category Detail View

struct CategoryDetailView: View {
    let summaryItem: SummaryItem
    let selectedCurrency: CurrencyType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with category info
                    VStack(spacing: 16) {
                        Image(systemName: Icon.categoryIcon(for: summaryItem.type))
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .frame(width: 120, height: 120)
                            .background(Color.categoryColor(for: summaryItem.type))
                            .clipShape(Circle())
                            .shadow(color: Color.categoryColor(for: summaryItem.type).opacity(0.3), radius: 10, x: 0, y: 5)
                            .background(Color.white)
                        
                        Text(summaryItem.type.capitalized)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("\(String(format: "%.1f", summaryItem.pct))% of total expenses")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Main statistics
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        DetailStatCard(
                            title: "Total Amount",
                            value: formatAmount(convertAmount(summaryItem.totalAmount, to: selectedCurrency), currency: selectedCurrency.symbol),
                            subtitle: "All time",
                            icon: "dollarsign.circle.fill",
                            color: .green
                        )
                        
                        DetailStatCard(
                            title: "Monthly Average",
                            value: formatAmount(convertAmount(summaryItem.amountPerMonth, to: selectedCurrency), currency: selectedCurrency.symbol),
                            subtitle: "Per month",
                            icon: "calendar.circle.fill",
                            color: .blue
                        )
                        
                        DetailStatCard(
                            title: "Total Items",
                            value: "\(summaryItem.numberOfItems)",
                            subtitle: "Transactions",
                            icon: "number.circle.fill",
                            color: .orange
                        )
                        
                        DetailStatCard(
                            title: "Average per Item",
                            value: formatAmount(convertAmount(summaryItem.totalAmount / Double(summaryItem.numberOfItems), to: selectedCurrency), currency: selectedCurrency.symbol),
                            subtitle: "Per transaction",
                            icon: "divide.circle.fill",
                            color: .purple
                        )
                    }
                    
                    // Additional insights
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Insights")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        InsightCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Spending Pattern",
                            description: getSpendingInsight(for: summaryItem),
                            color: .indigo
                        )
                        
                        InsightCard(
                            icon: "target",
                            title: "Budget Impact",
                            description: getBudgetInsight(for: summaryItem),
                            color: .teal
                        )
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
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
    
    
    private func formatAmount(_ amount: Double?, currency: String) -> String {
        guard let amount = amount else { return "\(currency)0.00" }
        return String(format: "\(currency)%.2f", amount)
    }
    
    private func convertAmount(_ eurAmount: Double, to currency: CurrencyType) -> Double {
        switch currency {
        case .eur: return eurAmount
        case .usd: return eurAmount * 1.1
        case .cad: return eurAmount * 1.5
        case .pln: return eurAmount * 4.3
        case .other: return eurAmount
        }
    }
    
    private func getSpendingInsight(for item: SummaryItem) -> String {
        let avgPerItem = item.totalAmount / Double(item.numberOfItems)
        if avgPerItem > 100 {
            return "High-value transactions. Consider reviewing for optimization opportunities."
        } else if item.numberOfItems > 50 {
            return "Frequent small transactions. This category shows consistent spending patterns."
        } else {
            return "Moderate spending pattern with balanced frequency and amounts."
        }
    }
    
    private func getBudgetInsight(for item: SummaryItem) -> String {
        if item.pct > 30 {
            return "Major budget category. This represents a significant portion of your expenses."
        } else if item.pct > 15 {
            return "Moderate budget impact. Consider tracking this category closely."
        } else {
            return "Minor budget category. Represents a small portion of total expenses."
        }
    }
}

// MARK: - Quick Stat View

struct QuickStatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Detail Stat Card

struct DetailStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}



// MARK: - View Types

enum ContentViewType {
    case text
    case plot
    case summary
}

extension Expense {
    static let columnWidths = [
        12, // date
        12, // type
        30, // description
        10, // eur
        10, // usd
        10, // cad
        12, // daily_total
        10  // bank
    ]
    
    static func formattedHeader() -> String {
        return [
            "date".padding(toLength: columnWidths[0], withPad: " ", startingAt: 0),
            "type".padding(toLength: columnWidths[1], withPad: " ", startingAt: 0),
            "description".padding(toLength: columnWidths[2], withPad: " ", startingAt: 0),
            "eur".padding(toLength: columnWidths[3], withPad: " ", startingAt: 0),
            "usd".padding(toLength: columnWidths[4], withPad: " ", startingAt: 0),
            "cad".padding(toLength: columnWidths[5], withPad: " ", startingAt: 0),
            "daily_total".padding(toLength: columnWidths[6], withPad: " ", startingAt: 0),
            "bank".padding(toLength: columnWidths[7], withPad: " ", startingAt: 0)
        ].joined(separator: " | ")
    }
}

extension SummaryItem {
    static let columnWidths = [
        15, // Category
        15, // Total Amount
        15, // Monthly Avg
        10, // Percentage
        10  // Items
    ]
    
    static func formattedHeader() -> String {
        return [
            "Category".padding(toLength: columnWidths[0], withPad: " ", startingAt: 0),
            "Total (€)".padding(toLength: columnWidths[1], withPad: " ", startingAt: 0),
            "Monthly (€)".padding(toLength: columnWidths[2], withPad: " ", startingAt: 0),
            "Pct (%)".padding(toLength: columnWidths[3], withPad: " ", startingAt: 0),
            "Items".padding(toLength: columnWidths[4], withPad: " ", startingAt: 0)
        ].joined(separator: " | ")
    }
}

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

        default:
            return .gray
        }
    }
}


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
            return "person.crop.circle.badge.arrow.forward"
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
        default:
            return "questionmark"
        }
    }
}
