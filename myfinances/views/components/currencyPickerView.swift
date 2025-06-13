import SwiftUI

struct CurrencyPickerView: View {
    @Binding var selectedCurrency: CurrencyType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(CurrencyType.allCases) { currency in
                Button(action: {
                    selectedCurrency = currency
                    dismiss()
                }) {
                    HStack(spacing: 12) {
                        Text(currency.flag)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currency.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(currency.code) • \(currency.symbol)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedCurrency == currency {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
