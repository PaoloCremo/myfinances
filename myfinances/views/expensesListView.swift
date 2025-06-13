import SwiftUI

struct ExpenseListView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.expenses) { expense in
                    ExpenseCardView(
                        expense: expense,
                        selectedCurrency: viewModel.selectedCurrency
                    )
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.loadExpenses()
        }
    }
}
