import SwiftUI
import Charts

struct MoodStat: Identifiable {
    let mood: String
    let count: Int
    var id: String { mood }
}

struct StatisticsView: View {
    @State private var moodStats: [MoodStat] = []
    @State private var errorMessage: String?
    @State private var isLoading = true

    let firestoreService = FirestoreService()

    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = errorMessage {
                    Text("⚠️ Hata: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding(.top, 50)
                    Spacer()
                } else if isLoading {
                    Spacer()
                    ProgressView("Yükleniyor...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        .scaleEffect(1.5)
                    Spacer()
                } else if moodStats.isEmpty {
                    Spacer()
                    Text("Hiç mood verisi bulunamadı.")
                        .foregroundColor(.gray)
                        .font(.headline)
                    Spacer()
                } else {
                    VStack(alignment: .leading) {
                        Text("Mood Dağılımı")
                            .font(.title2.bold())
                            .padding(.horizontal)

                        Chart(moodStats) { stat in
                            BarMark(
                                x: .value("Mood", stat.mood),
                                y: .value("Sayısı", stat.count)
                            )
                            .foregroundStyle(by: .value("Mood", stat.mood))
                            .annotation(position: .top) {
                                Text("\(stat.count)")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                        .frame(height: 300)
                        .padding(.horizontal)

                        Divider().padding(.top)

                        List {
                            ForEach(moodStats) { stat in
                                HStack {
                                    Text(stat.mood)
                                        .font(.largeTitle)
                                    Text(moodName(for: stat.mood))
                                        .font(.body)
                                    Spacer()
                                    Text("\(stat.count) kez")
                                        .fontWeight(.medium)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
            }
            .navigationTitle("İstatistikler")
            .onAppear(perform: loadStats)
        }
    }

    func loadStats() {
        isLoading = true
        firestoreService.fetchMoodEntries { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let entries):
                    let grouped = Dictionary(grouping: entries, by: { $0.mood })
                    let stats = grouped.map { MoodStat(mood: $0.key, count: $0.value.count) }
                    self.moodStats = stats.sorted { $0.count > $1.count }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    /// Emoji açıklamalarını gösteren yardımcı fonksiyon
    func moodName(for emoji: String) -> String {
        switch emoji {
        case "😊": return "Mutlu"
        case "😔": return "Üzgün"
        case "😠": return "Sinirli"
        case "😴": return "Yorgun"
        case "🥳": return "Neşeli"
        case "😢": return "Ağlamaklı"
        case "😇": return "Huzurlu"
        default: return ""
        }
    }
}
