import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreService {
    private let db = Firestore.firestore()

    // MARK: - Helpers

    private func userDoc() throws -> DocumentReference {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "No user", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu yok"])
        }
        return db.collection("users").document(uid)
    }

    // MARK: - MOOD ENTRIES

    func addMoodEntry(_ entry: MoodEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let user = try userDoc()
            let entryRef = user.collection("moodEntries").document(entry.id)

            entryRef.setData(entry.asDictionary) { [weak self] error in
                if let error = error { return completion(.failure(error)) }

                // Seçili hedefler varsa ilerlemeyi güncelle
                guard let self, !entry.goalIds.isEmpty else {
                    return completion(.success(()))
                }
                self.updateGoalsProgress(goalIDs: entry.goalIds, on: entry.date) { progressResult in
                    switch progressResult {
                    case .success: completion(.success(()))
                    case .failure(let e): completion(.failure(e))
                    }
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func updateMoodEntry(_ entry: MoodEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let user = try userDoc()
            let entryRef = user.collection("moodEntries").document(entry.id)

            entryRef.setData(entry.asDictionary, merge: true) { [weak self] error in
                if let error = error { return completion(.failure(error)) }

                // Hedefler güncellenmiş olabilir -> ilerlemeyi o gün için işaretle
                guard let self, !entry.goalIds.isEmpty else {
                    return completion(.success(()))
                }
                self.updateGoalsProgress(goalIDs: entry.goalIds, on: entry.date) { result in
                    switch result {
                    case .success: completion(.success(()))
                    case .failure(let e): completion(.failure(e))
                    }
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func fetchMoodEntries(completion: @escaping (Result<[MoodEntry], Error>) -> Void) {
        do {
            let user = try userDoc()
            user.collection("moodEntries")
                .order(by: "date", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error { return completion(.failure(error)) }

                    let entries: [MoodEntry] = snapshot?.documents.compactMap {
                        MoodEntry(from: $0.data(), documentID: $0.documentID)
                    } ?? []

                    completion(.success(entries))
                }
        } catch {
            completion(.failure(error))
        }
    }

    func deleteMoodEntry(_ entry: MoodEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let user = try userDoc()
            user.collection("moodEntries").document(entry.id).delete { error in
                error != nil ? completion(.failure(error!)) : completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }

    func deleteMultipleMoodEntries(_ entries: [MoodEntry], completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var deletionError: Error?

        for entry in entries {
            group.enter()
            deleteMoodEntry(entry) { result in
                if case .failure(let error) = result { deletionError = error }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let e = deletionError { completion(.failure(e)) } else { completion(.success(())) }
        }
    }

    // MARK: - MOOD GOALS (doc-bazlı)

    func addMoodGoal(_ goal: MoodGoal, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let user = try userDoc()
            user.collection("moodGoals").document(goal.id).setData(goal.asDictionary) { error in
                error != nil ? completion(.failure(error!)) : completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }

    func updateMoodGoal(_ goal: MoodGoal, completion: @escaping (Result<Void, Error>) -> Void) {
        // başlık/emoji/targetCount güncellemeleri için
        addMoodGoal(goal, completion: completion)
    }

    func fetchMoodGoals(completion: @escaping (Result<[MoodGoal], Error>) -> Void) {
        do {
            let user = try userDoc()
            user.collection("moodGoals")
                .order(by: "createdAt", descending: true) // createdAt: TimeInterval (number) -> orderBy ok
                .getDocuments { snapshot, error in
                    if let error = error { return completion(.failure(error)) }

                    let goals: [MoodGoal] = snapshot?.documents.compactMap {
                        MoodGoal(from: $0.data())
                    } ?? []

                    completion(.success(goals))
                }
        } catch {
            completion(.failure(error))
        }
    }

    func deleteMoodGoal(_ goal: MoodGoal, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let user = try userDoc()
            user.collection("moodGoals").document(goal.id).delete { error in
                error != nil ? completion(.failure(error!)) : completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }

    func deleteMultipleMoodGoals(_ goals: [MoodGoal], completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var deletionError: Error?

        for goal in goals {
            group.enter()
            deleteMoodGoal(goal) { result in
                if case .failure(let error) = result { deletionError = error }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let e = deletionError { completion(.failure(e)) } else { completion(.success(())) }
        }
    }

    // MARK: - Progress

    /// Seçilen hedefler için verilen tarihe bir “tamamlandı” işareti ekler.
    /// Aynı gün tekrar eklenmez.
    func updateGoalsProgress(goalIDs: [String], on date: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !goalIDs.isEmpty else { return completion(.success(())) }

        do {
            let user = try userDoc()
            let calendar = Calendar.current
            let dayStart = calendar.startOfDay(for: date)

            let group = DispatchGroup()
            var lastError: Error?

            for goalID in goalIDs {
                group.enter()
                let ref = user.collection("moodGoals").document(goalID)

                ref.getDocument { snapshot, error in
                    defer { group.leave() }

                    if let error = error { lastError = error; return }

                    guard let data = snapshot?.data(), var goal = MoodGoal(from: data) else {
                        // hedef yoksa sessiz geç
                        return
                    }

                    // aynı günü tekrar sayma
                    let existingDays = Set(goal.completedDates.map { calendar.startOfDay(for: $0) })
                    if !existingDays.contains(dayStart) {
                        goal.completedDates.append(date)
                        ref.setData(goal.asDictionary, merge: false) { err in
                            if let err = err { lastError = err }
                        }
                    }
                }
            }

            group.notify(queue: .main) {
                if let e = lastError { completion(.failure(e)) } else { completion(.success(())) }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
