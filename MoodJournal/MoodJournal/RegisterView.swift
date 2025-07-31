import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Text("Kayıt Ol")
                    .font(.title)
                    .fontWeight(.bold)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                SecureField("Şifre (min 6 karakter)", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                SecureField("Şifre (tekrar)", text: $confirmPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: {
                    guard password == confirmPassword else {
                        authVM.errorMessage = "Şifreler uyuşmuyor!"
                        return
                    }
                    
                    guard password.count >= 6 else {
                        authVM.errorMessage = "Şifre en az 6 karakter olmalı!"
                        return
                    }

                    authVM.signUp(email: email, password: password)
                    // dismiss() çağırmıyoruz çünkü user güncellenince otomatik yönleniyor
                }) {
                    Text("Hesap Oluştur")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }

                Button("Zaten hesabım var") {
                    // dismiss()
                }
                .font(.footnote)
            }
            .padding()
        }
    }
}
