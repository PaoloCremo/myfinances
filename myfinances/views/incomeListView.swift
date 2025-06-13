import SwiftUI

struct IncomeListView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.income) { income in
                    IncomeCardView(
                        income: income,
                        selectedCurrency: viewModel.selectedCurrency
                    )
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.loadIncome()
        }
    }
}
