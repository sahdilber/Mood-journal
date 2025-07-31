import SwiftUI
import FirebaseAuth
import UserNotifications

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    // 🔔 Bildirimle ilgili durumlar
    @State private var notificationsEnabled = false
    @State private var notificationTime = Date()
    @State private var showSaveSuccess = false

    var body: some View {
        NavigationView {
            Form {
                // 👤 Kullanıcı Bilgileri
                Section(header: Text("Hesap Bilgileri")) {
                    if let email = authVM.user?.email {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(email)
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    } else {
                        Text("Kullanıcı bilgisi alınamadı.")
                            .foregroundColor(.red)
                    }
                }

                // 🔧 İşlemler
                Section(header: Text("İşlemler")) {
                    NavigationLink("Şifreyi Değiştir") {
                        ChangePasswordView()
                    }

                    Button("Çıkış Yap", role: .destructive) {
                        authVM.signOut()
                    }
                }

                // 🔔 Bildirim Ayarları
                Section(header: Text("Bildirim Ayarları")) {
                    Toggle("Bildirimleri Aç", isOn: $notificationsEnabled)

                    if notificationsEnabled {
                        DatePicker("Saat Seç", selection: $notificationTime, displayedComponents: .hourAndMinute)

                        Button(action: saveNotificationSettings) {
                            Text("Bildirimleri Kaydet")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top)

                        if showSaveSuccess {
                            Text("✅ Bildirim ayarları kaydedildi!")
                                .foregroundColor(.green)
                                .font(.footnote)
                        }
                    }
                }
            }
            .navigationTitle("Profil")
            .onAppear(perform: loadNotificationStatus)
        }
    }

    // 🔔 Bildirimleri ayarla
    func saveNotificationSettings() {
        if notificationsEnabled {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: notificationTime)
            let minute = calendar.component(.minute, from: notificationTime)

            NotificationManager.shared.scheduleDailyNotification(at: hour, minute: minute)
            print("📬 Bildirim açıldı: \(hour):\(minute)")
        } else {
            NotificationManager.shared.cancelNotifications()
            print("🔕 Bildirimler kapatıldı")
        }

        showSaveSuccess = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showSaveSuccess = false
        }
    }

    // 🔍 Daha önce bildirim varsa toggle açık başlasın
    func loadNotificationStatus() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                self.notificationsEnabled = requests.contains { $0.identifier == "dailyMoodReminder" }
            }
        }
    }
}
