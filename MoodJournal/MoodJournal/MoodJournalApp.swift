import SwiftUI
import FirebaseCore
import UserNotifications

@main
struct MoodJournalApp: App {
    @StateObject private var authVM = AuthViewModel()
    @State private var showSplash = true

    init() {
        // 🔥 Firebase başlatılır
        FirebaseApp.configure()

        // 🔔 Bildirim yetkilendirme ve delegate ayarı
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView()
                    .onAppear {
                        // ⏳ 2.5 saniye sonra splash kapanır
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                ContentView()
                    .environmentObject(authVM)
            }
        }
    }

    // 🔐 Bildirim izni
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
