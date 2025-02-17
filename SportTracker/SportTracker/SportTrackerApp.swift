import SwiftUI
import SwiftData
import FirebaseCore

@main
struct SportTrackerApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SportPerformance.self)
    }
}
