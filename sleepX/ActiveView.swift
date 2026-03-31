//
//  ActiveView.swift
//  sleepX
//
//  Placeholder screen for active sleep tracking.
//

import SwiftUI
import Combine

final class ActiveViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    // Bluetooth/scoring state will be added here later.
}

struct ActiveView: View {
    @StateObject private var viewModel = ActiveViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Active")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 24)

            Text("Tracking is running. (Bluetooth + scoring coming next.)")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Active View")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.bottom, 24)
    }
}

#Preview {
    NavigationStack {
        ActiveView()
    }
}

