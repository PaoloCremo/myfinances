//
//  ForexAPI.swift
//  myfinances
//
//  Created by Paolo Cremonese on 2025-06-12.
//
import SwiftUI

struct APIConfig {
    static var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "ExchangeAPIKey") as? String else {
            fatalError("API Key not found in Info.plist")
        }
        return key
    }
    
    static var baseURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else {
            fatalError("Base URL not found in Info.plist")
        }
        return url
    }
}
