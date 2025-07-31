import SwiftUI
import FirebaseCore
import UserNotifications

@main
struct MoodJournalApp: App {
    @StateObject private var authVM = AuthViewModel()

    init() {
        // 🔥 Firebase başlatılır
        FirebaseApp.configure()

        // 🔔 Bildirim yetkilendirme ve delegate ayarı
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
        }
    }

    // 🔐 Uygulama başlarken izin iste
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Bildirim izni hatası: \(error.localizedDescription)")
            } else {
                print(granted ? "✅ Bildirim izni verildi" : "⚠️ Bildirim izni reddedildi")
            }
        }
    }
}
