import SwiftUI

struct NewEntryView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedMood = ""
    @State private var note = ""
    @State private var isSaving = false
    @State private var showSaved = false

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
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 6)
                        }
                        Text(buttonLabel)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(isSaving ? Color.gray : Color.green)
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

    var buttonLabel: String {
        if isSaving {
            return "Kaydediliyor..."
        } else if showSaved {
            return "Kaydedildi ✅"
        } else {
            return "Kaydet"
        }
    }

    func saveEntry() {
        guard !selectedMood.isEmpty else { return }

        isSaving = true
        showSaved = false

        let newEntry = MoodEntry(mood: selectedMood, note: note)

        firestoreService.addMoodEntry(newEntry) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    showSaved = true
                    isSaving = false
                    onEntryAdded?()
                    print("🟢 Kayıt başarılı")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        presentationMode.wrappedValue.dismiss()
                    }

                case .failure(let error):
                    isSaving = false
                    print("❌ Firestore Hatası: \(error.localizedDescription)")
                }
            }
        }
    }
}
