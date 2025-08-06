import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    private let db = Firestore.firestore()

    // MARK: - MOOD ENTRIES

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
                error != nil ? completion(.failure(error!)) : completion(.success(()))
            }
    }

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
                error != nil ? completion(.failure(error!)) : completion(.success(()))
            }
    }

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

                let entries = snapshot?.documents.compactMap {
                    MoodEntry(from: $0.data(), documentID: $0.documentID)
                } ?? []

                completion(.success(entries))
            }
    }

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
                error != nil ? completion(.failure(error!)) : completion(.success(()))
            }
    }

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
            deletionError != nil ? completion(.failure(deletionError!)) : completion(.success(()))
        }
    }

    // MARK: - MOOD GOALS (Belge bazlı)

    func addMoodGoal(_ goal: MoodGoal, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user", code: 401)))
            return
        }

        db.collection("users")
            .document(uid)
            .collection("moodGoals")
            .document(goal.id)
            .setData(goal.asDictionary) { error in
                error != nil ? completion(.failure(error!)) : completion(.success(()))
            }
    }

    func fetchMoodGoals(completion: @escaping (Result<[MoodGoal], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user", code: 401)))
            return
        }

        db.collection("users")
            .document(uid)
            .collection("moodGoals")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let goals: [MoodGoal] = snapshot?.documents.compactMap {
                    MoodGoal(from: $0.data())
                } ?? []

                completion(.success(goals))
            }
    }

    func deleteMoodGoal(_ goal: MoodGoal, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user", code: 401)))
            return
        }

        db.collection("users")
            .document(uid)
            .collection("moodGoals")
            .document(goal.id)
            .delete { error in
                error != nil ? completion(.failure(error!)) : completion(.success(()))
            }
    }

    func deleteMultipleMoodGoals(_ goals: [MoodGoal], completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var deletionError: Error?

        for goal in goals {
            group.enter()
            deleteMoodGoal(goal) { result in
                if case .failure(let error) = result {
                    deletionError = error
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            deletionError != nil ? completion(.failure(deletionError!)) : completion(.success(()))
        }
    }
}
