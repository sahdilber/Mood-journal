import SwiftUI
import FirebaseCore

@main
struct MoodJournalApp: App {
    @StateObject private var authVM = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM) // ✅ Her zaman ViewModel’i verir
        }
    }
}
