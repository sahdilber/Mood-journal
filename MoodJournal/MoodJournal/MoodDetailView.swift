import SwiftUI

struct MoodDetailView: View {
    let entry: MoodEntry
    var onDelete: (() -> Void)?
    var onEdit: ((MoodEntry) -> Void)?

    @Environment(\.dismiss) var dismiss
    @State private var showEdit = false
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            // 🎨 Arka plan
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // 😊 Mood
                Text(entry.mood)
                    .font(.system(size: 80))
                    .padding(.top)

                // 📅 Tarih
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))

                // ✍️ Not alanı
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

                // 🛠️ Butonlar
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

        // ✏️ Edit Sheet
        .sheet(isPresented: $showEdit) {
            EditEntryView(entry: entry) { updatedEntry in
                onEdit?(updatedEntry)
                dismiss()
            }
        }

        // 🗑️ Silme Alert
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
}
