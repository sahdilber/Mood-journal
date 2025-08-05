import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 28) {
                    VStack(spacing: 6) {
                        Text("Kayıt Ol")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Aramıza katıl, ruh halini kaydetmeye başla!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2)))

                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            SecureField("Şifre (min 6 karakter)", text: $password)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2)))

                        HStack {
                            Image(systemName: "lock.rotation")
                                .foregroundColor(.gray)
                            SecureField("Şifre (tekrar)", text: $confirmPassword)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2)))
                    }
                    .foregroundColor(.white)

                    if let error = authVM.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .transition(.opacity)
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
                    }) {
                        Text("Hesap Oluştur")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.gradient)
                            .cornerRadius(14)
                            .shadow(radius: 5)
                    }

                    Button("Zaten hesabım var") {
                        dismiss()
                    }
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                    .underline()
                }
                .padding()
                .padding(.top, 50)
            }
        }
    }
}
