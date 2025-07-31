import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    private let db = Firestore.firestore()

    // MARK: - Mood Kaydı Ekleme
    func addMoodEntry(_ entry: MoodEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("🚫 Kullanıcı yok")
            completion(.failure(NSError(domain: "No user", code: 401)))
            return
        }

        print("📤 Firestore’a kayıt başlıyor: \(entry)")

        db.collection("users")
            .document(uid)
            .collection("moodEntries")
            .document(entry.id)
            .setData(entry.asDictionary) { error in
                if let error = error {
                    print("❌ Firestore setData hatası: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("✅ Firestore setData başarılı")
                    completion(.success(()))
                }
            }
    }
    // MARK: - Mood Kayıtlarını Getir
    func fetchMoodEntries(completion: @escaping (Result<[MoodEntry], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user", code: 401)))
            return
        }

        db.collection("users")
            .document(uid)
            .collection("moodEntries")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let entries: [MoodEntry] = snapshot?.documents.compactMap { doc in
                    MoodEntry(from: doc.data(), documentID: doc.documentID)
                } ?? []

                completion(.success(entries))
            }
    }

    // MARK: - Tek Mood Kaydı Sil
    func deleteMoodEntry(_ entry: MoodEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user", code: 401)))
            return
        }

        guard !entry.id.isEmpty else {
            completion(.failure(NSError(domain: "No entry ID", code: 400)))
            return
        }

        db.collection("users")
            .document(uid)
            .collection("moodEntries")
            .document(entry.id)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    // MARK: - Çoklu Mood Kaydı Sil
    func deleteMultipleMoodEntries(_ entries: [MoodEntry], completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var deletionError: Error?

        for entry in entries {
            group.enter()
            deleteMoodEntry(entry) { result in
                if case .failure(let error) = result {
                    deletionError = error
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let error = deletionError {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
