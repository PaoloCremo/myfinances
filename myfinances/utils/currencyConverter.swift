import SwiftUI
import Foundation

@MainActor
class CurrencyConverter: ObservableObject {
    @Published var exchangeRates: [String: Double] = [:]
    @Published var isLoading = false
    @Published var lastUpdated: Date?
    
    private var apiKey: String {
            return APIConfig.apiKey
        }
        
    private var baseURL: String {
            return APIConfig.baseURL
        }
    
    // Cache rates for 1 hour to avoid excessive API calls
    private let cacheExpirationTime: TimeInterval = 3600 // 1 hour
    
    init() {
        loadCachedRates()
        Task {
            await fetchExchangeRatesIfNeeded()
        }
    }
    
    // MARK: - API Integration
    
    func fetchExchangeRatesIfNeeded() async {
        // Check if we need to refresh rates
        if let lastUpdated = lastUpdated,
           Date().timeIntervalSince(lastUpdated) < cacheExpirationTime {
            return // Rates are still fresh
        }
        
        await fetchExchangeRates()
    }
    
    func fetchExchangeRates() async {
        isLoading = true
        
        guard let url = URL(string: "https://\(baseURL)/\(apiKey)/latest/EUR") else {
            print("Invalid URL")
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
            
            if response.result == "success" {
                exchangeRates = response.conversion_rates
                lastUpdated = Date()
                saveRatesToCache()
                print("Exchange rates updated successfully")
            } else {
                print("API returned error: \(response.error_type ?? "Unknown error")")
            }
        } catch {
            print("Failed to fetch exchange rates: \(error.localizedDescription)")
            // Use fallback rates if API fails
            useFallbackRates()
        }
        
        isLoading = false
    }
    
    // MARK: - Conversion Methods
    
    static func formatAmount(_ amount: Double?, currency: String) -> String {
        guard let amount = amount else { return "\(currency)0.00" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currency)0.00"
    }
    
    static func amountColorExp(_ amount: Double?) -> Color {
        guard let amount = amount else { return .green }
        return amount >= 0 ? .red : .green
    }
    
    static func amountColorIn(_ amount: Double?) -> Color {
        guard let amount = amount else { return .primary }
        return amount >= 0 ? .green : .primary
    }
    
    func convertAmount(_ eurAmount: Double, to currency: CurrencyType) -> Double {
        switch currency {
        case .eur:
            return eurAmount
        case .usd:
            return eurAmount * (exchangeRates["USD"] ?? 1.10)
        case .cad:
            return eurAmount * (exchangeRates["CAD"] ?? 1.50)
        case .pln:
            return eurAmount * (exchangeRates["PLN"] ?? 4.30)
        case .other:
            return eurAmount
        }
    }
    
    func getExchangeRate(for currency: CurrencyType) -> Double {
        switch currency {
        case .eur: return 1.0
        case .usd: return exchangeRates["USD"] ?? 1.10
        case .cad: return exchangeRates["CAD"] ?? 1.50
        case .pln: return exchangeRates["PLN"] ?? 4.30
        case .other: return 1.0
        }
    }
    
    // MARK: - Cache Management
    
    private func saveRatesToCache() {
        let cacheData = CachedRates(rates: exchangeRates, timestamp: lastUpdated ?? Date())
        if let encoded = try? JSONEncoder().encode(cacheData) {
            UserDefaults.standard.set(encoded, forKey: "cached_exchange_rates")
        }
    }
    
    private func loadCachedRates() {
        guard let data = UserDefaults.standard.data(forKey: "cached_exchange_rates"),
              let cached = try? JSONDecoder().decode(CachedRates.self, from: data) else {
            return
        }
        
        // Check if cached data is still valid (within 1 hour)
        if Date().timeIntervalSince(cached.timestamp) < cacheExpirationTime {
            exchangeRates = cached.rates
            lastUpdated = cached.timestamp
        }
    }
    
    // MARK: - Fallback Rates
    
    private func useFallbackRates() {
        exchangeRates = [
            "USD": 1.10,
            "CAD": 1.50,
            "PLN": 4.30,
            "GBP": 0.85,
            "JPY": 165.0,
            "CHF": 0.95
        ]
        lastUpdated = Date()
        print("Using fallback exchange rates")
    }
    
    // MARK: - Utility Methods
    
    func refreshRates() {
        Task {
            await fetchExchangeRates()
        }
    }
    
    var formattedLastUpdated: String {
        guard let lastUpdated = lastUpdated else { return "Never" }
        let formatter = Foundation.DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: lastUpdated)
    }
}

// MARK: - Supporting Models

struct ExchangeRateResponse: Codable {
    let result: String
    let documentation: String?
    let terms_of_use: String?
    let time_last_update_unix: Int?
    let time_last_update_utc: String?
    let time_next_update_unix: Int?
    let time_next_update_utc: String?
    let base_code: String
    let conversion_rates: [String: Double]
    let error_type: String?
}

struct CachedRates: Codable {
    let rates: [String: Double]
    let timestamp: Date
}

// MARK: - Currency Status View

struct CurrencyStatusView: View {
    @ObservedObject var converter: CurrencyConverter
    
    var body: some View {
        HStack(spacing: 8) {
            if converter.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Updating rates...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Rates updated")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(converter.formattedLastUpdated)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button("Refresh") {
                converter.refreshRates()
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
