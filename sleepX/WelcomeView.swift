// Welcome landing screen and entry into sign-in.
import SwiftUI
import Combine

final class WelcomeViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    @Published var projectName: String = "Night Watch"
}
//UI
struct WelcomeView: View {
    @StateObject private var viewModel = WelcomeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                // Title
                Text(viewModel.projectName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Spacer()

                // Welcome action
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
            // Navigation bar
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    WelcomeView()
}
