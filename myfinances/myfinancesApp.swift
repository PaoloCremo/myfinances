//
// myfinancesApp.swift
// myfinances
//
// Created by Paolo Cremonese on 2025-06-11.
//

import SwiftUI

struct LandingPage: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Title section
                VStack(spacing: 10) {
                    Text("My Finances")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("Manage your expenses with style")
                        .font(.system(size: 18))
                        .foregroundStyle(Color(white: 0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Feature buttons - PUT THE NAVIGATIONLINKS HERE
                VStack(spacing: 20) {
                    NavigationLink(destination: ExpenseAppView(initialAction: "loadExpenses")) {
                        FeatureButton(
                            title: "Load Expenses",
                            subtitle: "View your spending history",
                            icon: "list.bullet.rectangle.portrait",
                            color: .blue
                        )
                    }
                    
                    NavigationLink(destination: ExpenseAppView(initialAction: "showSummary")) {
                        FeatureButton(
                            title: "Show Summary",
                            subtitle: "Get insights on your spending",
                            icon: "chart.bar.doc.horizontal",
                            color: .orange
                        )
                    }
                    
                    NavigationLink(destination: ExpenseAppView(initialAction: "showPlot")) {
                        FeatureButton(
                            title: "Show Plot",
                            subtitle: "Visualize your data",
                            icon: "chart.line.downtrend.xyaxis",
                            color: .purple
                        )
                    }

                    NavigationLink(destination: ExpenseAppView(initialAction: "loadIncome")) {
                        FeatureButton(
                            title: "Load Income",
                            subtitle: "Visualize your data",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .green
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Text("More features coming soon!")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(white: 0.6))
                    .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        }
    }
}


struct FeatureButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon container
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.7))
            }
            
            Spacer()
            
            // Arrow indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(white: 0.5))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// App entry point
@main
struct ExpenseTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            LandingPage()
        }
    }
}
