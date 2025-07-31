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
            VStack(spacing: 20) {
                Text("Modunu Düzenle")
                    .font(.title2)
                    .padding(.top)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(moodOptions, id: \.self) { mood in
                            Text(mood)
                                .font(.system(size: 40))
                                .padding()
                                .background(selectedMood == mood ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(12)
                                .onTapGesture {
                                    selectedMood = mood
                                }
                        }
                    }
                    .padding(.horizontal)
                }

                TextField("Notunu güncelle...", text: $note, axis: .vertical)
                    .lineLimit(3...5)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)

                Button(action: updateEntry) {
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 6)
                        }
                        Text("Kaydet")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(isSaving ? Color.gray : Color.orange)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .disabled(isSaving)

                Spacer()
            }
            .padding()
            .navigationTitle("Mood Düzenle")
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
                    print("🟢 EditEntryView → Firestore güncelleme başarılı")
                    onEntryUpdated?()     // 🔁 HomeView'da listeyi yeniler
                    dismiss()
                case .failure(let error):
                    print("❌ Güncelleme hatası: \(error.localizedDescription)")
                }
            }
        }
    }
}
