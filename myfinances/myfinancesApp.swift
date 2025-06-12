//
//  myfinancesApp.swift
//  myfinances
//
//  Created by Paolo Cremonese on 2025-06-11.
//

import SwiftUI

struct LandingPage: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Title label
                Text("Welcome to the Expense Tracker")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Description label
                Text("Manage your expenses efficiently and visualize your spending habits.")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(white: 0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Start button
                NavigationLink(destination: ExpenseAppView()) {
                    Text("Get Started")
                        .frame(width: 200, height: 50)
                        .background(Color(red: 0.2, green: 0.6, blue: 0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(50)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        }
    }
}

//struct ExpenseAppView: View {
//    var body: some View {
//        Text("Main App Screen")
//            // Replace with your ExpenseApp implementation
//    }
//}

// App entry point
@main
struct ExpenseTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            LandingPage()
        }
    }
}
