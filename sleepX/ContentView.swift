//
//  ContentView.swift
//  sleepX
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SleepScoreViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                SleepScoreIndexView(viewModel: viewModel)

                NavigationLink(destination: ActiveView()) {
                    Text("Start tracking")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.top, 8)

                NavigationLink(destination: SleepSummaryView()) {
                    Text("Summary View")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(14)
                }
            }
            .padding()
        }
        .navigationTitle("Score View")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
