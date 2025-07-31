import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    // 📢 Bildirim izni iste
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Bildirim izni hatası: \(error.localizedDescription)")
            } else {
                print("🔔 Bildirim izni verildi mi? \(granted)")
            }
        }
    }

    // 📅 Günlük hatırlatma bildirimi planla
    func scheduleDailyNotification(at hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Mood zamanı!"
        content.body = "Bugünkü ruh halini kaydetmeyi unutma 😊"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "dailyMoodReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Bildirim planlama hatası: \(error.localizedDescription)")
            } else {
                print("✅ Günlük bildirim başarıyla ayarlandı")
            }
        }
    }

    // 🧹 Bildirimleri temizle
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🧹 Tüm bildirimler iptal edildi")
    }
}
