import Foundation
import SwiftUI

@MainActor
class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var summaryData: [SummaryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentView: ContentViewType = .text
    @Published var selectedCurrency: CurrencyType = .cad
    @Published var currencyConverter = CurrencyConverter()
    
    private let networkManager = NetworkManager()
    
    func initializeWith(action: String) {
        switch action {
        case "loadExpenses":
            selectedCurrency = .cad
            loadExpenses()
        case "showSummary":
            selectedCurrency = .eur
            showSummary()
        case "showPlot":
            selectedCurrency = .eur
            showPlot()
        default:
            break
        }
    }
    
    func loadExpenses() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await networkManager.fetchExpenses()
                expenses = Array(result.prefix(100))
                currentView = .text
            } catch {
                errorMessage = "Error loading expenses: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    func showSummary() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                summaryData = try await networkManager.fetchSummary()
                currentView = .summary
            } catch {
                errorMessage = "Error loading summary: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    func showPlot() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                summaryData = try await networkManager.fetchSummary()
                currentView = .plot
            } catch {
                errorMessage = "Error loading plot data: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    func clearDisplay() {
        expenses = []
        summaryData = []
        currentView = .text
        errorMessage = nil
    }
}
