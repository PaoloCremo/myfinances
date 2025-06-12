//
//  myfinancesApp.swift
//  myfinances
//
//  Created by Paolo Cremonese on 2025-06-11.
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
    
    let host = "fastapi.paolocremonese.com"
    
    var body: some View {
        VStack(spacing: 0) {
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
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    switch currentView {
                    case .text:
                        VStack(spacing: 0) {
                            // Header
                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(headerText)
                                    .font(.system(.body, design: .monospaced))
                                    .padding(.horizontal)
                            }
                            .frame(height: 24)
                            .background(Color(.systemBackground))
                            
                            // Content
                            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                                Text(displayText)
                                    .font(.system(.body, design: .monospaced))
                                    .textSelection(.enabled)
                                    .padding(.horizontal)
                            }
                        }
                        
                    case .plot:
                        Chart(summaryData) { item in
                            BarMark(
                                x: .value("Category", item.type),
                                y: .value("Percentage", item.pct)
                            )
                            .foregroundStyle(by: .value("Category", item.type))
                        }
                        .chartXAxisLabel("Category")
                        .chartYAxisLabel("Percentage (%)")
                        .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
    
    private func loadExpenses() {
        isLoading = true
        errorMessage = nil
        
        let url = URL(string: "https://\(host)/expenses")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { isLoading = false }
            
            if let error = error {
                errorMessage = "Error loading expenses: \(error.localizedDescription)"
                return
            }
            
            guard let data = data else {
                errorMessage = "No data received"
                return
            }
            
            do {
                let result: ExpenseResponse = try JSONDecoder().decode(ExpenseResponse.self, from: data)
                let dfText = result.expenses.prefix(100).map { $0.description }.joined(separator: "\n")
                
                DispatchQueue.main.async {
                    // headerText = result.columns.joined(separator: "  ")
                    headerText = Expense.formattedHeader()
                    displayText = dfText
                    currentView = .text
                }
            } catch {
                errorMessage = "Error parsing data: \(error.localizedDescription)"
            }
        }.resume()
    }
    
    private func showSummary() {
        isLoading = true
        errorMessage = nil
        
        let url = URL(string: "https://\(host)/expenses/summary")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { isLoading = false }
            
            if let error = error {
                errorMessage = "Error loading summary: \(error.localizedDescription)"
                return
            }
            
            guard let data = data else {
                errorMessage = "No data received"
                return
            }
            
            do {
                let result = try JSONDecoder().decode(SummaryResponse.self, from: data)
                let summaryText = result.summary.map { $0.description }.joined(separator: "\n")
                
                DispatchQueue.main.async {
                    headerText = SummaryItem.formattedHeader()
                    displayText = summaryText
                    currentView = .text
                }
            } catch {
                errorMessage = "Error parsing summary: \(error.localizedDescription)"
            }
        }.resume()
    }
    
    private func showPlot() {
        isLoading = true
        errorMessage = nil
        
        let url = URL(string: "https://\(host)/expenses/summary")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { isLoading = false }
            
            if let error = error {
                errorMessage = "Error loading plot data: \(error.localizedDescription)"
                return
            }
            
            guard let data = data else {
                errorMessage = "No data received"
                return
            }
            
            do {
                let result = try JSONDecoder().decode(SummaryResponse.self, from: data)
                DispatchQueue.main.async {
                    summaryData = result.summary
                    currentView = .plot
                }
            } catch {
                errorMessage = "Error parsing plot data: \(error.localizedDescription)"
            }
        }.resume()
    }
    
    private func clearDisplay() {
        displayText = "Display cleared. Click a button to load data."
        headerText = ""
        currentView = .text
    }

}

// MARK: - Helper Components
struct ActionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

// MARK: - Data Models
struct ExpenseResponse: Codable {
    let columns: [String]
    let expenses: [Expense]
}

struct Expense: Codable, CustomStringConvertible {
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
        [
            type.padding(toLength: Self.columnWidths[0], withPad: " ", startingAt: 0),
            String(format: "%.2f", totalAmount).padding(toLength: Self.columnWidths[1], withPad: " ", startingAt: 0),
            String(format: "%.2f", amountPerMonth).padding(toLength: Self.columnWidths[2], withPad: " ", startingAt: 0),
            String(format: "%.1f", pct).padding(toLength: Self.columnWidths[3], withPad: " ", startingAt: 0),
            String(numberOfItems).padding(toLength: Self.columnWidths[4], withPad: " ", startingAt: 0)
        ].joined(separator: " | ")
    }
}

// MARK: - View Types
enum ContentViewType {
    case text
    case plot
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
        [
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

    var description: String {
        [
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

extension SummaryItem {
    static let columnWidths = [
        15, // Category
        15, // Total Amount
        15, // Monthly Avg
        10, // Percentage
        10  // Items
    ]
    
    static func formattedHeader() -> String {
        [
            "Category".padding(toLength: columnWidths[0], withPad: " ", startingAt: 0),
            "Total (€)".padding(toLength: columnWidths[1], withPad: " ", startingAt: 0),
            "Monthly (€)".padding(toLength: columnWidths[2], withPad: " ", startingAt: 0),
            "Pct (%)".padding(toLength: columnWidths[3], withPad: " ", startingAt: 0),
            "Items".padding(toLength: columnWidths[4], withPad: " ", startingAt: 0)
        ].joined(separator: " | ")
    }
}