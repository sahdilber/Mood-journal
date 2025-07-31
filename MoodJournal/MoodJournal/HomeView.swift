import SwiftUI

struct HomeView: View {
    @State private var moodEntries: [MoodEntry] = []
    @State private var showNewEntry = false
    @State private var showStatistics = false
    @State private var errorMessage: String?
    @State private var listID = UUID()
    @State private var selectedEntryForEdit: MoodEntry?

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
                            .onTapGesture {
                                selectedEntryForEdit = entry
                            }
                        }
                        .onDelete(perform: deleteMood)
                    }
                    .id(listID)
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Mood Günlüğüm")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showStatistics = true
                    } label: {
                        Image(systemName: "chart.bar")
                    }
                }

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
                    showNewEntry = false
                    fetchEntries()
                }
            }
            .sheet(item: $selectedEntryForEdit) { entry in
                EditEntryView(entry: entry) {
                    selectedEntryForEdit = nil
                    fetchEntries()
                    listID = UUID()
                }
            }
            .sheet(isPresented: $showStatistics) {
                StatisticsView()
            }
            .onAppear {
                fetchEntries()
            }
            .onChange(of: showNewEntry) {
                if !showNewEntry {
                    fetchEntries()
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
                    self.listID = UUID()
                    print("📥 HomeView → fetchEntries başarılı. Entry sayısı: \(entries.count)")
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
                    fetchEntries()
                case .failure(let error):
                    self.errorMessage = "Silme hatası: \(error.localizedDescription)"
                }
            }
        }
    }
}
