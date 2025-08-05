import SwiftUI

struct EditEntryView: View {
    @Environment(\.dismiss) var dismiss

    @State private var selectedMood: String
    @State private var note: String
    @State private var isSaving = false

    let moodOptions = ["😊", "😔", "😠", "😴", "🥳", "😢", "😇"]
    let firestoreService = FirestoreService()
    let entry: MoodEntry

    // 🔁 Güncellenen mood’u geri döndür
    var onEntryUpdated: ((MoodEntry) -> Void)?

    init(entry: MoodEntry, onEntryUpdated: ((MoodEntry) -> Void)? = nil) {
        self.entry = entry
        _selectedMood = State(initialValue: entry.mood)
        _note = State(initialValue: entry.note)
        self.onEntryUpdated = onEntryUpdated
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 🎨 Arka plan
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("Modunu Düzenle")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)

                    // 😊 Mood seçenekleri
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(moodOptions, id: \.self) { mood in
                                Text(mood)
                                    .font(.system(size: 36))
                                    .padding()
                                    .background(selectedMood == mood ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(selectedMood == mood ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            selectedMood = mood
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // ✍️ Not alanı (sorunsuz TextEditor)
                    ZStack(alignment: .topLeading) {
                        if note.isEmpty {
                            Text("Notunu güncelle...")
                                .foregroundColor(.white.opacity(0.3))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                        }

                        TextEditor(text: $note)
                            .padding(12)
                            .frame(minHeight: 120)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.05)) // 👈 Siyahı engeller
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .foregroundColor(.white)
                            .font(.body)
                            .scrollContentBackground(.hidden) // 👈 iOS 16+ için önemli
                    }
                    .padding(.horizontal)

                    // 💾 Kaydet butonu
                    Button(action: updateEntry) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 6)
                            }
                            Text("Kaydet")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(colors: [Color.orange, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(16)
                        .shadow(radius: 6)
                    }
                    .disabled(isSaving)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
                .navigationTitle("Mood Düzenle")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    func updateEntry() {
        guard !selectedMood.isEmpty else { return }

        isSaving = true
        let updatedEntry = MoodEntry(id: entry.id, mood: selectedMood, note: note, date: entry.date)

        firestoreService.updateMoodEntry(updatedEntry) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    onEntryUpdated?(updatedEntry)
                    dismiss()
                case .failure(let error):
                    print("❌ Güncelleme hatası: \(error.localizedDescription)")
                }
            }
        }
    }
}
