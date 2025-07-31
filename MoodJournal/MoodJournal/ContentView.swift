import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.user != nil {
                HomeView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authVM.user) // ✅ Geçiş animasyonu
    }
}
