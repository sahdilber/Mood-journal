import SwiftUI
import Charts

struct MoodStat: Identifiable {
    let mood: String
    let count: Int
    var id: String { mood }
}
struct StatisticsView: View {
    @State private var moodStats: [MoodStat] = []
    @State private var moodEntries: [MoodEntry] = []
    @State private var errorMessage: String?
    @State private var selectedTab = 0

    let firestoreService = FirestoreService()
    let tabTitles = ["Grafik", "Takvim"]

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 📌 Üstte Sekmeli Geçiş
                HStack {
                    ForEach(0..<tabTitles.count, id: \.self) { index in
                        Button {
                            selectedTab = index
                        } label: {
                            Text(tabTitles[index])
                                .fontWeight(.semibold)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(selectedTab == index ? Color.orange.opacity(0.2) : Color.clear)
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)

                // 📄 Sayfa Görünümleri
                TabView(selection: $selectedTab) {
                    // Grafik Sayfası
                    VStack {
                        if let errorMessage = errorMessage {
                            Text("Hata: \(errorMessage)")
                                .foregroundColor(.red)
                                .padding()
                        } else if moodStats.isEmpty {
                            Spacer()
                            ProgressView("Yükleniyor...")
                            Spacer()
                        } else {
                            Chart(moodStats) { stat in
                                BarMark(
                                    x: .value("Mood", stat.mood),
                                    y: .value("Sayısı", stat.count)
                                )
                                .foregroundStyle(by: .value("Mood", stat.mood))
                            }
                            .frame(height: 300)
                            .padding()

                            List(moodStats) { stat in
                                HStack {
                                    Text(stat.mood)
                                        .font(.largeTitle)
                                    Spacer()
                                    Text("\(stat.count) kez")
                                }
                            }
                        }
                    }
                    .tag(0)

                    // Takvim Sayfası
                    CalendarView(moodEntries: moodEntries)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedTab)
            }
            .navigationTitle("İstatistikler")
            .onAppear(perform: loadStats)
        }
    }

    func loadStats() {
        firestoreService.fetchMoodEntries { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self.moodEntries = entries

                    let grouped = Dictionary(grouping: entries, by: { $0.mood })
                    let stats = grouped.map { (mood, group) in
                        MoodStat(mood: mood, count: group.count)
                    }
                    self.moodStats = stats.sorted { $0.count > $1.count }

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
