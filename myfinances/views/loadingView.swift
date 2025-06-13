import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { _ in
                ExpenseSkeletonView()
            }
        }
        .padding()
    }
}

struct ExpenseSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(.systemGray4))
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 6) {
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(height: 16)
                    .cornerRadius(4)
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 12)
                    .cornerRadius(3)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 60, height: 16)
                    .cornerRadius(4)
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 10)
                    .cornerRadius(3)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .opacity(isAnimating ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}
