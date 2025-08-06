import SwiftUI
import FirebaseAuth
import UserNotifications

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var notificationsEnabled = false
    @State private var notificationTime = Date()
    @State private var showSaveSuccess = false

    var body: some View {
        NavigationView {
            ZStack {
                // 🎨 Arka plan gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // 👤 Kullanıcı Bilgileri
                        ProfileCard(title: "👤 Hesap Bilgileri") {
                            if let email = authVM.user?.email {
                                InfoRow(label: "Email", value: email)
                            } else {
                                Text("Kullanıcı bilgisi alınamadı.")
                                    .foregroundColor(.red)
                            }
                        }

                        // 🎯 Mood Hedefleri
                        ProfileCard(title: "🎯 Mood Hedefleri") {
                            NavigationLink(destination: GoalsView()) {
                                HStack {
                                    Image(systemName: "target")
                                    Text("Hedeflerini Görüntüle")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                            }
                        }

                        // ⚙️ İşlemler
                        ProfileCard(title: "⚙️ İşlemler") {
                            NavigationLink(destination: ChangePasswordView()) {
                                HStack {
                                    Image(systemName: "key.fill")
                                    Text("Şifreyi Değiştir")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                            }

                            Button(role: .destructive) {
                                authVM.signOut()
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                    Text("Çıkış Yap")
                                    Spacer()
                                }
                                .foregroundColor(.red)
                                .padding(.vertical, 8)
                            }
                        }

                        // 🔔 Bildirim Ayarları
                        ProfileCard(title: "🔔 Bildirim Ayarları") {
                            Toggle("Bildirimleri Aç", isOn: $notificationsEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                .padding(.bottom, 8)

                            if notificationsEnabled {
                                DatePicker("Bildirim Saati", selection: $notificationTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .accentColor(.white)

                                Button(action: saveNotificationSettings) {
                                    Text("💾 Bildirimleri Kaydet")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .shadow(radius: 4)
                                }
                                .padding(.top)

                                if showSaveSuccess {
                                    Text("✅ Bildirim ayarları kaydedildi!")
                                        .foregroundColor(.green)
                                        .font(.footnote)
                                        .padding(.top, 6)
                                }
                            }
                        }
                    }
                    .padding()
                    .foregroundColor(.white)
                }
            }
            .navigationTitle("Profil")
            .onAppear(perform: loadNotificationStatus)
        }
    }

    // 🔧 Bildirim Kaydetme
    func saveNotificationSettings() {
        if notificationsEnabled {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: notificationTime)
            let minute = calendar.component(.minute, from: notificationTime)
            NotificationManager.shared.scheduleDailyNotification(at: hour, minute: minute)
        } else {
            NotificationManager.shared.cancelNotifications()
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

// 📦 Ortak Profil Kart Bileşeni
struct ProfileCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)

            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial.opacity(0.1))
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

// 🔤 Bilgi Satırı Bileşeni
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
                .font(.subheadline)
        }
    }
}
