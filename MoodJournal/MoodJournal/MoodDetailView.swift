import SwiftUI

struct MoodDetailView: View {
    let entry: MoodEntry
    @State var allGoals: [MoodGoal] = [] // ✅ let yerine @State yaptık

    var onDelete: (() -> Void)?
    var onEdit: ((MoodEntry) -> Void)?

    @Environment(\.dismiss) var dismiss
    @State private var showEdit = false
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(entry.mood)
                    .font(.system(size: 80))
                    .padding(.top)

                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))

                // 🎯 Hedefler gösterimi
                if !entry.goalIds.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(allGoals.filter { entry.goalIds.contains($0.id) }) { goal in
                                HStack {
                                    Text(goal.emoji)
                                    Text(goal.title)
                                        .font(.subheadline)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                if !entry.note.isEmpty {
                    ScrollView {
                        Text(entry.note)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: 300)
                } else {
                    Text("Not girilmemiş.")
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                HStack(spacing: 20) {
                    Button {
                        showEdit = true
                    } label: {
                        Label("Düzenle", systemImage: "pencil")
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Sil", systemImage: "trash")
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Mood Detayı")
        .navigationBarTitleDisplayMode(.inline)

        .onAppear {
            fetchGoals()
        }

        .sheet(isPresented: $showEdit) {
            EditEntryView(entry: entry, allGoals: allGoals) { updatedEntry in
                onEdit?(updatedEntry)
                dismiss()
            }
        }

        .alert("Bu mood silinsin mi?", isPresented: $showDeleteAlert) {
            Button("Sil", role: .destructive) {
                FirestoreService().deleteMoodEntry(entry) { _ in
                    onDelete?()
                    dismiss()
                }
            }
            Button("Vazgeç", role: .cancel) { }
        }
    }

    func fetchGoals() {
        FirestoreService().fetchMoodGoals { result in
            DispatchQueue.main.async {
                if case .success(let goals) = result {
                    self.allGoals = goals
                }
            }
        }
    }
}
