import SwiftUI

struct SummaryListView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.summaryData) { summaryItem in
                    SummaryCardView(
                        summaryItem: summaryItem,
                        selectedCurrency: viewModel.selectedCurrency,
                        currencyConverter: viewModel.currencyConverter // Pass the converter
                    )
                }
            }
            .padding()
        }
        .refreshable {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            viewModel.showSummary()
        }
    }
}
