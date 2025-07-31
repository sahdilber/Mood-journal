import SwiftUI

struct MainContainerView: View {
    @State private var selectedTab = 1 // Başlangıçta HomeView gösterilsin

    var body: some View {
        TabView(selection: $selectedTab) {
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("İstatistik")
                }
                .tag(0)

            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Anasayfa")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profil")
                }
                .tag(2)
        }
        .accentColor(.orange) // Seçili ikon rengi
    }
}
