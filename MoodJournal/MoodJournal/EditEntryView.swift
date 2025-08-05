import SwiftUI

struct EditEntryView: View {
    @Environment(\.dismiss) var dismiss

    @State private var selectedMood: String
    @State private var note: String
    @State private var isSaving = false

    let moodOptions = ["😊", "😔", "😠", "😴", "🥳", "😢", "😇"]
    let firestoreService = FirestoreService()
    let entry: MoodEntry

    var onEntryUpdated: (() -> Void)?

    init(entry: MoodEntry, onEntryUpdated: (() -> Void)? = nil) {
        self.entry = entry
        _selectedMood = State(initialValue: entry.mood)
        _note = State(initialValue: entry.note)
        self.onEntryUpdated = onEntryUpdated
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 🎨 Gradient arka plan
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

                    // Mood seçenekleri
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

                    // Not güncelleme alanı
                    TextField("Notunu güncelle...", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.2))
                        )
                        .cornerRadius(14)
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    // Kaydet butonu
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
                    onEntryUpdated?()
                    dismiss()
                case .failure(let error):
                    print("❌ Güncelleme hatası: \(error.localizedDescription)")
                }
            }
        }
    }
}
