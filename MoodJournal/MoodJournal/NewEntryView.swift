import SwiftUI

struct NewEntryView: View {
    @Environment(\.dismiss) var dismiss // ✅ modern yol

    @State private var selectedMood = ""
    @State private var note = ""
    @State private var isSaving = false

    let moodOptions = ["😊", "😔", "😠", "😴", "🥳", "😢", "😇"]
    let firestoreService = FirestoreService()

    var onEntryAdded: (() -> Void)?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Bugünkü modun nasıl?")
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

                TextField("Kısa bir not ekle...", text: $note, axis: .vertical)
                    .lineLimit(3...5)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)

                Button(action: saveEntry) {
                    Text("Kaydet")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(isSaving)

                Spacer()
            }
            .padding()
            .navigationTitle("Yeni Mood Girişi")
        }
    }

    func saveEntry() {
        guard !selectedMood.isEmpty else {
            print("⚠️ Mood seçilmedi")
            return
        }

        isSaving = true
        print("⏳ Kayıt işlemi başlıyor...")

        let newEntry = MoodEntry(mood: selectedMood, note: note)

        firestoreService.addMoodEntry(newEntry) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    print("🟢 NewEntryView → Firestore başarılı döndü.")
                    onEntryAdded?() // Sheet kapatmayı HomeView yapar
                case .failure(let error):
                    print("❌ NewEntryView → Firestore hata verdi: \(error.localizedDescription)")
                }
            }
        }
    }
}
