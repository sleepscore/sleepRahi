// Sign-in with username and PIN; navigates to home or create-account.
import SwiftUI
import Combine

final class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var pin: String = ""
    @Published var errorMessage: String?

    private let accountStore: LocalAccountStore

    init(accountStore: LocalAccountStore = .shared) {
        self.accountStore = accountStore
    }

    //Correct Form Validation
    var canSubmit: Bool {
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && pin.count >= 4
    }

    // Sign in
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
        guard accountStore.verify(username: trimmed, pin: pin) else {
            errorMessage = "Unknown username or incorrect PIN. Make sure to create an account first."
            return false
        }
        return true
    }
}
//UI
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var navigateToHome = false

    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 24)

            // Username
            TextField("Username", text: $viewModel.username)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

            // PIN
            SecureField("PIN", text: $viewModel.pin)
                .textContentType(.oneTimeCode)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .onChange(of: viewModel.pin) { _, newValue in
                    let digitsOnly = newValue.filter(\.isNumber)
                    if digitsOnly != newValue { viewModel.pin = digitsOnly }
                }

            // Error
            if let message = viewModel.errorMessage {
                Text(message)
                    .foregroundStyle(.red)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Submit
            Button {
                if viewModel.submit() {
                    navigateToHome = true
                }
            } label: {
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

            // Create account
            NavigationLink(destination: CreateAccountView()) {
                Text("Create an account")
                    .fontWeight(.medium)
            }
            .padding(.top, 4)

            Spacer()
        }
        .padding(.horizontal)
        // Navigation bar
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToHome) {
            ContentView()
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
