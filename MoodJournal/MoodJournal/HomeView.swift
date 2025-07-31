import SwiftUI

struct HomeView: View {
    @State private var moodEntries: [MoodEntry] = []
    @State private var showNewEntry = false
    @State private var errorMessage: String?
    @State private var listID = UUID()

    let firestoreService = FirestoreService()

    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = errorMessage {
                    Text("Hata: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }

                if moodEntries.isEmpty {
                    Spacer()
                    Text("Hiç mood girişi yok.")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(moodEntries) { entry in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(entry.mood)
                                    .font(.title2)
                                if !entry.note.isEmpty {
                                    Text(entry.note)
                                        .font(.body)
                                }
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteMood)
                    }
                    .id(listID) // 🔁 Listeyi sıfırdan oluştur (çökmeleri önle)
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Mood Günlüğüm")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewEntry) {
                NewEntryView {
                    // onEntryAdded closure burada boş çünkü .onChange ile yakalıyoruz
                }
            }
            .onAppear {
                fetchEntries()
            }
            .onChange(of: showNewEntry) {
                if !showNewEntry {
                    fetchEntries() // ✅ Sheet kapandıysa listeyi güvenli yenile
                }
            }
        }
    }

    func fetchEntries() {
        firestoreService.fetchMoodEntries { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self.moodEntries = entries
                    self.listID = UUID() // 🔁 Listeyi sıfırla (çökmeleri önle)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func deleteMood(at offsets: IndexSet) {
        let entriesToDelete = offsets.map { moodEntries[$0] }

        firestoreService.deleteMultipleMoodEntries(entriesToDelete) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    fetchEntries() // ✅ Silme sonrası güvenli yeniden yükleme
                case .failure(let error):
                    self.errorMessage = "Silme hatası: \(error.localizedDescription)"
                }
            }
        }
    }
}
