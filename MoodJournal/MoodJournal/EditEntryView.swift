import SwiftUI

struct EditEntryView: View {
    @Environment(\.dismiss) var dismiss

    @State private var selectedMood: String
    @State private var note: String
    @State private var isSaving = false
    @State private var selectedGoalIds: Set<String>

    let moodOptions = ["😊", "😔", "😠", "😴", "🥳", "😢", "😇"]
    let firestoreService = FirestoreService()
    let entry: MoodEntry
    let allGoals: [MoodGoal]

    var onEntryUpdated: ((MoodEntry) -> Void)?

    init(entry: MoodEntry, allGoals: [MoodGoal], onEntryUpdated: ((MoodEntry) -> Void)? = nil) {
        self.entry = entry
        self.allGoals = allGoals
        _selectedMood = State(initialValue: entry.mood)
        _note = State(initialValue: entry.note)
        _selectedGoalIds = State(initialValue: Set(entry.goalIds))
        self.onEntryUpdated = onEntryUpdated
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
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

                        // 🎯 Hedef seçimi
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bugün hangi hedefleri gerçekleştirdin?")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                                .padding(.horizontal)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
                                ForEach(allGoals) { goal in
                                    let isSelected = selectedGoalIds.contains(goal.id)

                                    HStack {
                                        Text(goal.emoji)
                                        Text(goal.title)
                                            .lineLimit(1)
                                    }
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        if isSelected {
                                            selectedGoalIds.remove(goal.id)
                                        } else {
                                            selectedGoalIds.insert(goal.id)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // ✍️ Not alanı
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
                                        .fill(Color.white.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                                .foregroundColor(.white)
                                .font(.body)
                                .scrollContentBackground(.hidden)
                        }
                        .padding(.horizontal)

                        // 💾 Kaydet
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
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Mood Düzenle")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func updateEntry() {
        guard !selectedMood.isEmpty else { return }

        isSaving = true
        let updatedEntry = MoodEntry(
            id: entry.id,
            mood: selectedMood,
            note: note,
            date: entry.date,
            goalIds: Array(selectedGoalIds)
        )

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
