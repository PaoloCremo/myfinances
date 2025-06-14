//
//  AuthManager.swift
//  myfinances
//
//  Created by Paolo Cremonese on 2025-06-14.
//

import Foundation

actor AuthManager {
    static let shared = AuthManager()
    
    private var currentToken: Token?
    private var refreshTask: Task<Void, Error>?
    
    private let username = fastAPIConfig.username
    private let password = fastAPIConfig.password
    private let host = fastAPIConfig.baseURL
    private let session = URLSession.shared
    
    struct Token: Codable {
        let accessToken: String
        let expiresAt: Date
    }
    
    func login() async throws -> Token {
        let url = URL(string: "https://\(host)/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "username=\(username)&password=\(password)"
        request.httpBody = body.data(using: .utf8)
        
        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        return Token(
            accessToken: response.access_token,
            expiresAt: Date().addingTimeInterval(1800) // 30-minute expiration
        )
    }
    
    private init() {
        Task { try await loadStoredToken() }
    }
    
    func validAccessToken() async throws -> String {
            if let token = currentToken, token.expiresAt > Date() {
                return token.accessToken
            }
            // This will trigger a new login if token is expired or missing
            let token = try await login()
            currentToken = token
            // Schedule refresh after token expires
            scheduleRefresh()
            return token.accessToken
        }
    
    private func loadStoredToken() async throws {
            do {
                currentToken = try KeychainHelper.shared.read(
                    service: "finance-app",
                    account: "tokens"
                )
                // If token is stored and still valid, schedule refresh
                if let token = currentToken, token.expiresAt > Date() {
                    scheduleRefresh()
                }
            } catch {
                currentToken = nil
            }
        }
    
    private func scheduleRefresh() {
            // Cancel any existing refresh task
            refreshTask?.cancel()
            guard let expiresAt = currentToken?.expiresAt else { return }
            let timeInterval = expiresAt.timeIntervalSinceNow
            guard timeInterval > 0 else { return }
        
            // Schedule refresh just before token expires (e.g., 1 minute before, or right after)
            refreshTask = Task {
                try await Task.sleep(nanoseconds: UInt64(timeInterval * 1_000_000_000))
                // After token expires, clear current token so next call to validAccessToken will login again
                currentToken = nil
            }
        }
    
    enum AuthError: Error {
        case missingRefreshToken
        case tokenRefreshFailed
    }
    
    struct TokenResponse: Decodable {
        let access_token: String
    }
}
