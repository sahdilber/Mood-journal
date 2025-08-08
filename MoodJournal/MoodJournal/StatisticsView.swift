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
    @State private var isLoading = true   // 👈 Yükleniyor mu?

    let firestoreService = FirestoreService()
    let tabTitles = ["Grafik", "Takvim"]

    var body: some View {
        NavigationView {
            ZStack {
                // 🌈 Arka plan (uygulama teması ile uyumlu)
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    // 📌 Üst sekmeler
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
                                            .fill(selectedTab == index ? Color.blue.opacity(0.4) : Color.white.opacity(0.08))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)

                    // 📊 İçerikler
                    TabView(selection: $selectedTab) {
                        // ---------- Grafik Sekmesi ----------
                        VStack {
                            if let errorMessage = errorMessage {
                                Text("Hata: \(errorMessage)")
                                    .foregroundColor(.red)
                                    .padding()
                                Spacer()
                            } else if isLoading {
                                Spacer()
                                ProgressView("Yükleniyor...")
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .foregroundColor(.white)
                                Spacer()
                            } else if moodEntries.isEmpty {
                                // 👉 Veri yok boş durumu (ortalanmış)
                                Spacer()
                                VStack(spacing: 12) {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.white.opacity(0.5))
                                    Text("Henüz mood girişi yok.")
                                        .foregroundColor(.white.opacity(0.85))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
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
                                .padding(.horizontal)
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
                                    AxisMarks(preset: .aligned)
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading)
                                }

                                // 🔢 Kart listesi
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
                                                            .stroke(Color.white.opacity(0.18))
                                                    )
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .tag(0)

                        // ---------- Takvim Sekmesi ----------
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

    // MARK: - Data
    func loadStats() {
        isLoading = true
        errorMessage = nil

        firestoreService.fetchMoodEntries { result in
            DispatchQueue.main.async {
                isLoading = false
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
