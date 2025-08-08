import SwiftUI

struct GoalsView: View {
    @State private var moodGoals: [MoodGoal] = []
    @State private var showAddGoal = false
    @State private var errorMessage: String?

    let firestoreService = FirestoreService()

    var body: some View {
        NavigationView {
            ZStack {
                // 🌈 App temasıyla uyumlu arka plan
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                content
            }
            .navigationTitle("Mood Hedefleri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddGoal = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showAddGoal, onDismiss: fetchGoals) {
                AddGoalView { _ in
                    // AddGoalView Firestore’a kaydediyor, dönüşte listeyi tazeliyoruz
                    fetchGoals()
                }
            }
        }
        .onAppear(perform: fetchGoals)
    }

    // MARK: - Content
    @ViewBuilder
    private var content: some View {
        VStack {
            if let errorMessage = errorMessage {
                Text("Hata: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }

            if moodGoals.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "target")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white.opacity(0.5))
                    Text("Henüz hedef eklemedin.")
                        .foregroundColor(.white.opacity(0.85))
                }
                Spacer()
            } else {
                List {
                    ForEach(moodGoals) { goal in
                        goalRow(goal)
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteGoals)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .refreshable { fetchGoals() }
            }
        }
        .padding()
    }

    // MARK: - Row
    @ViewBuilder
    private func goalRow(_ goal: MoodGoal) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(goal.emoji)
                    .font(.system(size: 30))

                Text(goal.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if goal.isCompleted {
                    Text("✅")
                        .font(.headline)
                        .transition(.scale)
                }
            }

            // İlerleme barı + etiketler
            VStack(alignment: .leading, spacing: 6) {
                // Custom progress bar (daha görünür)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(
                            colors: [Color.green, Color.blue],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: max(0, min(1, goal.completionRate)) * UIScreen.main.bounds.width * 0.6,
                               height: 12)
                }

                HStack(spacing: 10) {
                    Label("\(goal.completedDates.count)/\(goal.targetCount) gün",
                          systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))

                    if streak(for: goal) > 0 {
                        Text("🔥 \(streak(for: goal)) gün seri")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.25))
                            .foregroundColor(.orange)
                            .clipShape(Capsule())
                            .accessibilityLabel("Streak: \(streak(for: goal)) gün")
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                deleteSingle(goal)
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
    }

    // MARK: - Firestore
    private func fetchGoals() {
        firestoreService.fetchMoodGoals { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let goals):
                    self.moodGoals = goals
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func deleteGoals(at offsets: IndexSet) {
        let toDelete = offsets.map { moodGoals[$0] }
        let group = DispatchGroup()
        var deletionError: Error?

        toDelete.forEach { goal in
            group.enter()
            firestoreService.deleteMoodGoal(goal) { result in
                if case .failure(let err) = result { deletionError = err }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let err = deletionError {
                self.errorMessage = "Silme hatası: \(err.localizedDescription)"
            }
            fetchGoals()
        }
    }

    private func deleteSingle(_ goal: MoodGoal) {
        firestoreService.deleteMoodGoal(goal) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.moodGoals.removeAll { $0.id == goal.id }
                case .failure(let error):
                    self.errorMessage = "Silme hatası: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Helpers
    /// Art arda gün sayısını hesaplar (bugünden geriye)
    private func streak(for goal: MoodGoal) -> Int {
        let days = Set(goal.completedDates.map { Calendar.current.startOfDay(for: $0) })
        guard !days.isEmpty else { return 0 }

        var streak = 0
        var cursor = Calendar.current.startOfDay(for: Date())

        while days.contains(cursor) {
            streak += 1
            cursor = Calendar.current.date(byAdding: .day, value: -1, to: cursor)!
        }
        return streak
    }
}
