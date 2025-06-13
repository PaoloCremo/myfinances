import SwiftUI

struct PlotView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    var body: some View {
        InteractiveChartView(
            summaryData: viewModel.summaryData,
            selectedCurrency: viewModel.selectedCurrency
        )
        .padding()
    }
}
