import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoOpacity = 0.0
    @State private var logoScale: CGFloat = 0.8
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if isActive {
                HomeView() // Giriş kontrolünü yapan view (örneğin: ContentView)
            } else {
                ZStack {
                    // 🎨 Arka plan - Moodiary temasına uygun gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color(red: 98/255, green: 74/255, blue: 204/255), Color.black]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    VStack(spacing: 16) {
                        // 🌟 Logo
                        Image("AppLogo") // ⚠️ AppAssets'te "AppLogo" adıyla olmalı
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .opacity(logoOpacity)
                            .scaleEffect(logoScale)
                            .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 4)

                        // 📝 Uygulama adı (isteğe bağlı)
                        Text("Moodiary")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .opacity(logoOpacity)
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        logoOpacity = 1.0
                        logoScale = 1.0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}
