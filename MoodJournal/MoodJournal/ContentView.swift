import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.user != nil {
                MainContainerView() // 🔁 Giriş yapıldıysa 3 sayfalı yapıya geç
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authVM.user)
    }
}
