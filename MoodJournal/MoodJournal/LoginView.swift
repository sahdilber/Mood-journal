import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    VStack(spacing: 6) {
                        Text("Moodiary")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Ruh halini kaydetmeye başla!")
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
                            SecureField("Şifre", text: $password)
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
                        guard !email.isEmpty, !password.isEmpty else {
                            authVM.errorMessage = "Lütfen tüm alanları doldurun."
                            return
                        }
                        authVM.signIn(email: email, password: password)
                    }) {
                        Text("Giriş Yap")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.gradient)
                            .cornerRadius(14)
                            .shadow(radius: 5)
                    }

                    Button {
                        showRegister = true
                    } label: {
                        Text("Hesabın yok mu? Kayıt ol")
                            .underline()
                            .foregroundColor(.white.opacity(0.9))
                            .font(.footnote)
                    }
                    .sheet(isPresented: $showRegister) {
                        RegisterView()
                            .environmentObject(authVM)
                    }
                }
                .padding()
                .padding(.top, 50)
            }
        }
    }
}
