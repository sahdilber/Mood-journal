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
            ZStack {
                // 🌈 Arka plan (Login ekranıyla uyumlu)
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    // 📌 Sekmeli geçiş
                    HStack(spacing: 12) {
                        ForEach(0..<tabTitles.count, id: \.self) { index in
                            Button {
                                selectedTab = index
                            } label: {
                                Text(tabTitles[index])
                                    .fontWeight(.semibold)
                                    .foregroundColor(selectedTab == index ? .white : .white.opacity(0.6))
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedTab == index ? Color.blue.opacity(0.4) : Color.white.opacity(0.1))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)

                    // 📊 Tab içerikleri
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
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Spacer()
                            } else {
                                // 📊 Bar Chart
                                Chart(moodStats) { stat in
                                    BarMark(
                                        x: .value("Mood", stat.mood),
                                        y: .value("Sayısı", stat.count)
                                    )
                                    .foregroundStyle(by: .value("Mood", stat.mood))
                                }
                                .frame(height: 300)
                                .padding()
                                .chartForegroundStyleScale([
                                    "😊": .yellow,
                                    "😔": .gray,
                                    "😠": .red,
                                    "😴": .blue,
                                    "🥳": .green,
                                    "😢": .cyan,
                                    "😇": .orange
                                ])
                                .chartXAxis {
                                    AxisMarks(preset: .aligned, values: .automatic)
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading)
                                }

                                // 🔢 Mood kart listesi
                                ScrollView {
                                    VStack(spacing: 10) {
                                        ForEach(moodStats) { stat in
                                            HStack {
                                                Text(stat.mood)
                                                    .font(.system(size: 34))

                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("\(stat.count) kez")
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                }

                                                Spacer()
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color.white.opacity(0.05))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(Color.white.opacity(0.2))
                                                    )
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
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
                .padding(.top)
            }
            .navigationTitle("İstatistikler")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: loadStats)
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
