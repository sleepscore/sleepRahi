// Register a new local username and PIN, with a success confirmation state.
import SwiftUI
import Combine

final class CreateAccountViewModel: ObservableObject {
    
    @Published var username: String = ""
    @Published var pin: String = ""
    @Published var confirmPin: String = ""
    @Published var errorMessage: String?

    private let store: LocalAccountStore

    init(store: LocalAccountStore = .shared) {
        self.store = store
    }

    // Form validation
    var canSubmit: Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && pin.count >= 4 && pin == confirmPin
    }

    // Persist new account
    func createAccount() -> Bool {
        errorMessage = nil
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { errorMessage = "Please enter a username."; return false }
        guard pin.count >= 4 else { errorMessage = "Please enter a PIN (at least 4 digits)."; return false }
        guard pin == confirmPin else { errorMessage = "PINs do not match."; return false }

        do {
            try store.register(username: trimmed, pin: pin)
            return true
        } catch LocalAccountStore.RegistrationError.usernameTaken {
            errorMessage = "That username is already taken."
            return false
        } catch {
            errorMessage = "Could not save account."
            return false
        }
    }
}

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateAccountViewModel()
    @State private var accountCreated = false

    var body: some View {
        VStack(spacing: 16) {
            if accountCreated {
                // Success state
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.green)

                Text("Account created!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("You can now sign in with your username and PIN.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button {
                    dismiss()
                } label: {
                    Text("Go to Sign In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
                .padding(.horizontal)

                Spacer()

            } else {
                // Form
                Text("Create account")
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

                TextField("PIN (digits only)", text: $viewModel.pin)
                    .keyboardType(.numberPad)
                    .textContentType(.none)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .onChange(of: viewModel.pin) { _, newValue in
                        let digits = newValue.filter(\.isNumber)
                        if digits != newValue { viewModel.pin = digits }
                    }

                TextField("Confirm PIN", text: $viewModel.confirmPin)
                    .keyboardType(.numberPad)
                    .textContentType(.none)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .onChange(of: viewModel.confirmPin) { _, newValue in
                        let digits = newValue.filter(\.isNumber)
                        if digits != newValue { viewModel.confirmPin = digits }
                    }

                if let message = viewModel.errorMessage {
                    Text(message)
                        .foregroundStyle(.red)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    if viewModel.createAccount() {
                        accountCreated = true
                    }
                } label: {
                    Text("Create account")
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
        }
        .padding(.horizontal)
        // Navigation bar
        .navigationTitle("Sign up")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut, value: accountCreated)

    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
