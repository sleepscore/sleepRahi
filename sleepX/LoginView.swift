//
//  LoginView.swift
//  sleepX
//
//  Created by OpenAI on 3/25/26.
//

import SwiftUI
import Combine

final class LoginViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    @Published var username: String = ""
    @Published var pin: String = ""
    @Published var errorMessage: String?

    var canSubmit: Bool {
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && pin.count >= 4
    }

    func submit() -> Bool {
        errorMessage = nil

        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a username."
            return false
        }
        guard pin.count >= 4 else {
            errorMessage = "Please enter a PIN (at least 4 digits)."
            return false
        }

        // Authentication logic can be wired to your backend later.
        return true
    }
}

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    private enum Destination: Hashable {
        case home
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 24)

                TextField("Username", text: $viewModel.username)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)

                SecureField("PIN", text: $viewModel.pin)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .onChange(of: viewModel.pin) { oldValue, newValue in
                        let digitsOnly = newValue.filter(\.isNumber)
                        if digitsOnly != newValue {
                            viewModel.pin = digitsOnly
                        }
                    }

                if let message = viewModel.errorMessage {
                    Text(message)
                        .foregroundStyle(.red)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                NavigationLink(value: Destination.home) {
                    Text("Enter")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(viewModel.canSubmit ? Color.accentColor : Color.gray.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!viewModel.canSubmit)
                .padding(.top, 8)

                Spacer()
            }
            .padding(.horizontal)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .home:
                    ContentView()
                }
            }
            .navigationTitle("Login View")
        }
    }
}

#Preview {
    LoginView()
}

