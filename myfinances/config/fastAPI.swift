//
//  fastAPI.swift
//  myfinances
//
//  Created by Paolo Cremonese on 2025-06-12.
//

import SwiftUI

struct fastAPIConfig {
    static var baseURL: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "fastAPIbaseURL") as? String else {
            fatalError("Base URL not found in Info.plist")
        }
        return key
    }
}
