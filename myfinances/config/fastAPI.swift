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

    static var username: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "fastAPIusername") as? String else {
            fatalError("FastAPI username not found in Info.plist")
        }
        return key
    }

    static var password: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "fastAPIpassword") as? String else {
            fatalError("FastAPI password not found in Info.plist")
        }
        return key
    }
}
