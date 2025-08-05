import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var isProcessing = false
    @State private var message: String?
    @State private var showAlert = false

    var body: some View {
        ZStack {
            // 🎨 Arka plan
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("🔒 Şifre Değiştir")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Group {
                        PasswordField(title: "Mevcut Şifre", text: $currentPassword)
                        PasswordField(title: "Yeni Şifre", text: $newPassword)
                        PasswordField(title: "Yeni Şifre (Tekrar)", text: $confirmPassword)
                    }

                    // 🟥 Hata Uyarıları
                    if !newPassword.isEmpty && newPassword.count < 6 {
                        Text("Yeni şifre en az 6 karakter olmalı.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    if !confirmPassword.isEmpty && newPassword != confirmPassword {
                        Text("Yeni şifreler eşleşmiyor.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Button(action: updatePassword) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 6)
                            }
                            Text("Şifreyi Güncelle")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    }
                    .disabled(!isFormValid || isProcessing)

                    if let message = message {
                        Text(message)
                            .foregroundColor(message.contains("✅") ? .green : .red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            .transition(.opacity)
                    }

                    Spacer()
                }
                .padding()
            }
        }
        .alert("Bilgilendirme", isPresented: $showAlert) {
            Button("Tamam") {
                if message?.contains("başarıyla") == true {
                    dismiss()
                }
            }
        } message: {
            Text(message ?? "")
        }
    }

    var isFormValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }

    func updatePassword() {
        guard let email = Auth.auth().currentUser?.email else {
            message = "Kullanıcı oturumu bulunamadı."
            showAlert = true
            return
        }

        isProcessing = true
        message = nil

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)

        Auth.auth().currentUser?.reauthenticate(with: credential) { result, error in
            if let error = error {
                message = "❌ Mevcut şifre hatalı: \(error.localizedDescription)"
                showAlert = true
                isProcessing = false
                return
            }

            Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                isProcessing = false
                if let error = error {
                    message = "❌ Şifre güncellenemedi: \(error.localizedDescription)"
                } else {
                    message = "✅ Şifre başarıyla güncellendi."
                }
                showAlert = true
            }
        }
    }
}

// 🔒 Ortak şifre alanı tasarımı
struct PasswordField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        SecureField(title, text: $text)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2)))
            .foregroundColor(.white)
            .autocapitalization(.none)
    }
}
