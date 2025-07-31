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
        Form {
            Section(header: Text("Mevcut Şifre")) {
                SecureField("Şu anki şifreniz", text: $currentPassword)
            }

            Section(header: Text("Yeni Şifre")) {
                SecureField("Yeni şifre", text: $newPassword)
                SecureField("Yeni şifre (tekrar)", text: $confirmPassword)

                if !newPassword.isEmpty && newPassword.count < 6 {
                    Text("Yeni şifre en az 6 karakter olmalı.")
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if !confirmPassword.isEmpty && newPassword != confirmPassword {
                    Text("Yeni şifreler eşleşmiyor.")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            Section {
                Button(action: updatePassword) {
                    HStack {
                        Spacer()
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Şifreyi Güncelle")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.purple)
                    .cornerRadius(10)
                }
                .disabled(!isFormValid || isProcessing)
            }

            if let message = message {
                Section {
                    Text(message)
                        .foregroundColor(message.contains("✅") ? .green : .red)
                }
            }
        }
        .navigationTitle("Şifreyi Değiştir")
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
