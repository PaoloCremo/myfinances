import SwiftUI
import Charts

struct InteractiveChartView: View {
    let summaryData: [SummaryItem]
    let selectedCurrency: CurrencyType
    @State private var selectedCategory: String? = nil
    @State private var showingDetail = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Expense Summary by Category")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)
            
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
                .animation(.easeInOut(duration: 0.3), value: selectedCategory)
            }
            .frame(maxHeight: 400)
            
            if !summaryData.isEmpty {
                QuickStatsView(summaryData: summaryData, selectedCurrency: selectedCurrency)
            }
            
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
}
