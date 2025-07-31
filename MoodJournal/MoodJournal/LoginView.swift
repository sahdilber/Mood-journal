import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Moodiary")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 10) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    SecureField("Şifre", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }

                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: {
                    guard !email.isEmpty, !password.isEmpty else {
                        authVM.errorMessage = "Lütfen tüm alanları doldurun."
                        return
                    }

                    authVM.signIn(email: email, password: password)
                    print("🟦 Giriş denendi: \(email)")
                }) {
                    Text("Giriş Yap")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Button("Hesabın yok mu? Kayıt ol") {
                    showRegister = true
                }
                .font(.footnote)
                .sheet(isPresented: $showRegister) {
                    RegisterView()
                        .environmentObject(authVM)
                }
            }
            .padding()
        }
    }
}
