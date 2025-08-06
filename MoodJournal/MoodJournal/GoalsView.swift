import SwiftUI

struct GoalsView: View {
    @State private var moodGoals: [MoodGoal] = []
    @State private var showAddGoal = false
    @State private var errorMessage: String?

    let firestoreService = FirestoreService()

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    if let errorMessage = errorMessage {
                        Text("Hata: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
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
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(moodGoals) { goal in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(goal.emoji)
                                            .font(.system(size: 32))

                                        Text(goal.title)
                                            .font(.headline)
                                            .foregroundColor(.white)

                                        Spacer()

                                        if goal.completedDates.count >= goal.targetCount {
                                            Text("✅")
                                        }
                                    }

                                    ProgressView(value: Float(goal.completedDates.count), total: Float(goal.targetCount)) {
                                        Text("Tamamlanan gün: \(goal.completedDates.count)/\(goal.targetCount)")
                                            .foregroundColor(.white.opacity(0.7))
                                            .font(.caption)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }
                            .onDelete(perform: deleteGoals)
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(.plain)
                    }
                }
                .padding()
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
                    AddGoalView(onGoalAdded: { newGoal in
                        moodGoals.append(newGoal)
                    })
                }
            }
        }
        .onAppear(perform: fetchGoals)
    }

    func fetchGoals() {
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

    func deleteGoals(at offsets: IndexSet) {
        let goalsToDelete = offsets.map { moodGoals[$0] }

        let dispatchGroup = DispatchGroup()
        var deletionError: Error?

        for goal in goalsToDelete {
            dispatchGroup.enter()
            firestoreService.deleteMoodGoal(goal) { result in
                if case .failure(let error) = result {
                    deletionError = error
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            if let error = deletionError {
                self.errorMessage = "Silme hatası: \(error.localizedDescription)"
            } else {
                fetchGoals()
            }
        }
    }
}
