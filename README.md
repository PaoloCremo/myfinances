# MyFinances

A SwiftUI-based iOS application for tracking and visualizing personal expenses across multiple currencies.

## Features

### Multi-Currency Support
- Track expenses in EUR, USD, CAD, PLN and other currencies
- Real-time currency conversion
- Automated exchange rate updates

### Expense Tracking
- View detailed expense entries
- Category-based organization
- Daily totals tracking
- Bank account tracking

### Visualization
- Interactive charts showing expense distribution
- Category-wise breakdowns
- Percentage-based analysis
- Monthly averages

### Summary Statistics
- Quick stats overview
- Category-wise summaries
- Monthly and per-item averages
- Spending pattern analysis

## Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository
2. Open `myfinances.xcodeproj` in Xcode
3. Configure the following in `Info.plist`:
   - `BaseURL`: Your exchange rate API base URL
   - `ExchangeAPIKey`: Your exchange rate API key
   - `fastAPIbaseURL`: Your backend API base URL

## Configuration

The app requires configuration of API endpoints and keys in the `config` folder:

- `ForexAPI.swift`: Exchange rate API configuration
- `fastAPI.swift`: Backend API configuration

## Architecture

### MVVM Architecture
- Views in `views` directory
- ViewModels in project root
- Models in `models` directory

### Networking
- `NetworkManager` for API communication
- `CurrencyConverter` for exchange rate handling

### Utilities
- Currency formatting
- Date formatting
- Custom extensions

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE.md) file for details.

## Contact

[paolocremonese.com](https://paolocremonese.com)