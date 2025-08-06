import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss

    @State private var goalTitle = ""
    @State private var selectedEmoji = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    let emojiOptions = ["🚶‍♀️", "🚴‍♂️", "📖", "🧘‍♀️", "🏃‍♂️", "🎨", "🎧", "🍵"]

    var onGoalAdded: ((MoodGoal) -> Void)?
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

                VStack(spacing: 24) {
                    Text("Yeni Hedef Ekle")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    TextField("Hedef (örn: Yürüyüş yap)", text: $goalTitle)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2)))
                        .foregroundColor(.white)
                        .autocapitalization(.sentences)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Text(emoji)
                                    .font(.system(size: 36))
                                    .padding()
                                    .background(selectedEmoji == emoji ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(selectedEmoji == emoji ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedEmoji = emoji
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }

                    Button(action: saveGoal) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Kaydet")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(goalTitle.isEmpty || selectedEmoji.isEmpty ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                    }
                    .disabled(goalTitle.isEmpty || selectedEmoji.isEmpty || isSaving)

                    Spacer()
                }
                .padding()
                .navigationTitle("Hedef Ekle")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Vazgeç") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    func saveGoal() {
        isSaving = true
        errorMessage = nil

        let newGoal = MoodGoal(title: goalTitle, emoji: selectedEmoji)

        firestoreService.addMoodGoal(newGoal) { result in
            DispatchQueue.main.async {
                isSaving = false

                switch result {
                case .success:
                    onGoalAdded?(newGoal)
                    dismiss()
                case .failure(let error):
                    errorMessage = "Kayıt hatası: \(error.localizedDescription)"
                }
            }
        }
    }
}
