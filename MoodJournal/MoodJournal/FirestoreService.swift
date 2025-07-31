import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    private let db = Firestore.firestore()

    // Mood Ekle
    func addMoodEntry(_ entry: MoodEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user", code: 401)))
            return
        }

        db.collection("users")
            .document(uid)
            .collection("moodEntries")
            .document(entry.id)
            .setData(entry.asDictionary) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    // Mood Güncelle
    func updateMoodEntry(_ entry: MoodEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user", code: 401)))
            return
        }

        db.collection("users")
            .document(uid)
            .collection("moodEntries")
            .document(entry.id)
            .setData(entry.asDictionary, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    // Mood Listele
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

    // Mood Sil
    func deleteMoodEntry(_ entry: MoodEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user", code: 401)))
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

    // Çoklu Mood Sil
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
