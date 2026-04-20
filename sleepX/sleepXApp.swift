// SwiftData container for persisted sleep results.
import SwiftUI
import SwiftData

@main
struct sleepXApp: App {
    var body: some Scene {
        WindowGroup {
            // Root
            WelcomeView()
        }
        // SwiftData persistence for SleepResult
        .modelContainer(for: SleepResult.self)
    }
}
