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
            ZStack(alignment: .bottomTrailing) {
                // 🎨 Gradient arka plan
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 12) {
                    if let errorMessage = errorMessage {
                        Text("Hata: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    }

                    if moodEntries.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "face.smiling")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white.opacity(0.5))

                            Text("Hiç mood girişi yok.")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(moodEntries) { entry in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .center, spacing: 16) {
                                        // Emoji (Mood)
                                        Text(entry.mood)
                                            .font(.system(size: 34))

                                        VStack(alignment: .leading, spacing: 6) {
                                            if !entry.note.isEmpty {
                                                Text(entry.note)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.white)
                                                    .lineLimit(2)
                                            }
                                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.6))
                                        }

                                        Spacer()
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white.opacity(0.05))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(LinearGradient(
                                                        colors: [Color.purple.opacity(0.5), Color.blue.opacity(0.5)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ), lineWidth: 1)
                                            )
                                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                                    )
                                    .onTapGesture {
                                        selectedEntryForEdit = entry
                                    }
                                }
                                .padding(.vertical, 4)
                                .listRowBackground(Color.clear)
                            }
                            .onDelete(perform: deleteMood)
                        }
                        .id(listID)
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }
                }
                .padding()

                // ➕ Yeni mood ekle butonu
                Button(action: {
                    showNewEntry = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.blue))
                        .shadow(radius: 6)
                }
                .padding()
            }
            .navigationTitle("Mood Günlüğüm")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.white)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showStatistics = true
                    } label: {
                        Image(systemName: "chart.bar")
                            .foregroundColor(.white)
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
