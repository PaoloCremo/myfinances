import SwiftUI

struct ExpenseListView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    var data: ExpenseListData
    var type: String = "999"
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                switch data {
                case .expenses(let expenses):
//                    Text("We are inside case .expenses  - Count: \(expenses.count)")
                    ForEach(expenses) { expense in
                        ExpenseCardView(
                            expense : expense,
                            selectedCurrency: viewModel.selectedCurrency
                        )
                    }
                    
                case .expensesByType(let expenses):
//                    Text("We are inside case .expensesByType - Count: \(expenses.count)")
                    ForEach(expenses) { expense in
                        ExpenseCardView(
                            expense : expense,
                            selectedCurrency: viewModel.selectedCurrency
                        )
                    }
                }
            }
            .padding()
        }
        .refreshable {
            switch data {
                case .expenses:
                    viewModel.loadExpenses()
                case .expensesByType:
                viewModel.loadExpensesByType(type: type)
            }
        }
    }
}
