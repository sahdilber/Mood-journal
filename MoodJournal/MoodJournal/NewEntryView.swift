import SwiftUI

struct NewEntryView: View {
    @Environment(\.dismiss) var dismiss

    @State private var selectedMood = ""
    @State private var note = ""
    @State private var isSaving = false
    @State private var showMoodAlert = false

    @State private var moodGoals: [MoodGoal] = []
    @State private var selectedGoalIds: Set<String> = []

    let moodOptions = ["😊", "😔", "😠", "😴", "🥳", "😢", "😇"]
    let firestoreService = FirestoreService()
    var onEntryAdded: (() -> Void)?

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("Bugünkü modun nasıl?")
                        .font(.title2).fontWeight(.semibold)
                        .foregroundColor(.white)

                    if !selectedMood.isEmpty {
                        Text(selectedMood)
                            .font(.system(size: 72))
                            .transition(.scale)
                    }

                    // Mood seçim
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
                                            showMoodAlert = false
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // 🎯 Hedef seçimi
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bugün hangi hedefleri gerçekleştirdin?")
                            .font(.headline)
                            .foregroundColor(.white)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                            ForEach(moodGoals) { goal in
                                Button {
                                    toggleGoal(goal.id)
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(goal.emoji).font(.system(size: 28))
                                        Text(goal.title)
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        selectedGoalIds.contains(goal.id)
                                        ? Color.green.opacity(0.2)
                                        : Color.white.opacity(0.05)
                                    )
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedGoalIds.contains(goal.id) ? Color.green : Color.clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Not
                    TextField("Kısa bir not ekle...", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.2), lineWidth: 1))
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    if showMoodAlert {
                        Text("Lütfen önce bir mood seç.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .transition(.opacity)
                    }

                    Button(action: saveEntry) {
                        Text("Kaydet")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(16)
                            .shadow(radius: 6)
                    }
                    .disabled(isSaving)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
                .navigationTitle("Yeni Mood Girişi")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear(perform: fetchGoals)
    }

    private func toggleGoal(_ id: String) {
        if selectedGoalIds.contains(id) { selectedGoalIds.remove(id) }
        else { selectedGoalIds.insert(id) }
    }

    private func fetchGoals() {
        firestoreService.fetchMoodGoals { result in
            DispatchQueue.main.async {
                if case .success(let goals) = result {
                    self.moodGoals = goals
                }
            }
        }
    }

    private func saveEntry() {
        guard !selectedMood.isEmpty else {
            withAnimation { showMoodAlert = true }
            return
        }

        isSaving = true
        let newEntry = MoodEntry(
            mood: selectedMood,
            note: note,
            goalIds: Array(selectedGoalIds)   // 👈 doğru anahtar
        )

        firestoreService.addMoodEntry(newEntry) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    onEntryAdded?()
                    dismiss()
                case .failure(let error):
                    print("❌ Kayıt hatası: \(error.localizedDescription)")
                }
            }
        }
    }
}
