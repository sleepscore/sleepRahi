//
//  ContentView.swift
//  sleepX
//
//  Created by Rahi Mehta on 3/24/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SleepScoreViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    SleepScoreIndexView(viewModel: viewModel)

                    // 3) Start tracking button
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

                    // Multi-day review
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
        }
    }
}

#Preview {
    ContentView()
}
