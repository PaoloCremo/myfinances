import Foundation
import SwiftUI

@MainActor
class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var expensesByType: [Expense] = []
    @Published var income: [Income] = []
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
        case "loadIncome":
            selectedCurrency = .cad
            loadIncome()
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
                expenses = result // Array(result.prefix(100))
                currentView = .text
            } catch {
                errorMessage = "Error HERE loading expenses: \(error.localizedDescription)"
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

    func loadIncome() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await networkManager.fetchIncome()
                income = result // Array(result.prefix(100))
                currentView = .income
            } catch {
                errorMessage = "Error loading incomes: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    func loadExpensesByType(type: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await networkManager.fetchExpensesByType(type: type)//summaryItem.type)
                expensesByType = result
                currentView = .text
            } catch {
                errorMessage = "Error loading expenses: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    func clearDisplay() {
        expenses = []
        summaryData = []
        currentView = .text
        income = []
        errorMessage = nil
    }
}
