//Navigation into live tracking and the sleep summary.
import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Start tracking
                NavigationLink(destination: ActiveView()) {
                    Text("Start tracking")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.top, 8)

                // Summary
                NavigationLink(destination: SleepSummaryView()) {
                    Text("Summary View")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(14)
                }
            }
            .padding()
        }
        // Navigation bar
        .navigationTitle("Home Page")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
