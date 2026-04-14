//
//  sleepXApp.swift
//  sleepX
//

import SwiftUI
import SwiftData

@main
struct sleepXApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
        // Single source of truth — SwiftData persists SleepResult to device storage
        .modelContainer(for: SleepResult.self)
    }
}
