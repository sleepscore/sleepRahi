//
//  WelcomeView.swift
//  sleepX
//

import SwiftUI
import Combine

final class WelcomeViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    @Published var projectName: String = "Sleep Score tracker"
}

struct WelcomeView: View {
    @StateObject private var viewModel = WelcomeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Text(viewModel.projectName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Spacer()

                NavigationLink(destination: LoginView()) {
                    Text("Welcome")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.top, 20)
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    WelcomeView()
}
