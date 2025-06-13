import SwiftUI

struct ExpenseAppView: View {
    @ObservedObject private var viewModel = ExpenseViewModel()
    @State private var showingCurrencyPicker = false
    
    let initialAction: String
    
    // Add this initializer
    init(initialAction: String) {
        self.initialAction = initialAction
    }
    
    var body: some View {
        VStack {
            // Header with currency selector
             HeaderView(
                 selectedCurrency: viewModel.selectedCurrency,
                 onCurrencyTap: { showingCurrencyPicker = true }
             )
             
             CurrencyStatusView(converter: viewModel.currencyConverter)
                             .padding(.horizontal)
            
            ActionButtonsView(viewModel: viewModel)
            
            // content
            ContentView(viewModel: viewModel)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .sheet(isPresented: $showingCurrencyPicker) {
            CurrencyPickerView(selectedCurrency: $viewModel.selectedCurrency)
        }
        .navigationTitle("My Finances")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.initializeWith(action: initialAction)
            switch initialAction {
            case "loadExpenses":
                viewModel.loadExpenses()
            case "showSummary":
                viewModel.showSummary()
            case "showPlot":
                viewModel.showPlot()
            default:
                break
            }
        }
    }

}


struct HeaderView: View {
    let selectedCurrency: CurrencyType
    let onCurrencyTap: () -> Void
    
    var body: some View {
        HStack {
            Text("My Finances")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: onCurrencyTap) {
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
    }
}

struct ActionButtonsView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            ActionButton(title: "Load Expenses") {
                viewModel.loadExpenses()
            }
            
            ActionButton(title: "Show Summary") {
                viewModel.showSummary()
            }
            
            ActionButton(title: "Show Plot") {
                viewModel.showPlot()
            }
            
            ActionButton(title: "Clear") {
                viewModel.clearDisplay()
            }
        }
        .padding()
        .frame(height: 60)
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error)
            } else {
                switch viewModel.currentView {
                case .text:
                    ExpenseListView(viewModel: viewModel)
                case .summary:
                    SummaryListView(viewModel: viewModel)
                case .plot:
                    PlotView(viewModel: viewModel)
                }
            }
        }
    }
}
