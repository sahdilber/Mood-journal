import Foundation
import FirebaseFirestore

struct MoodEntry: Identifiable, Equatable {
    let id: String
    let mood: String
    let note: String
    let date: Date
    let goalIds: [String] // ✅ küçük 'i'

    var asDictionary: [String: Any] {
        return [
            "id": id,
            "mood": mood,
            "note": note,
            "date": Timestamp(date: date),
            "goalIDs": goalIds // Firestore'da yine büyük I ile saklanıyor
        ]
    }

    init(
        id: String = UUID().uuidString,
        mood: String,
        note: String,
        date: Date = Date(),
        goalIds: [String] = []
    ) {
        self.id = id
        self.mood = mood
        self.note = note
        self.date = date
        self.goalIds = goalIds
    }

    init?(from dict: [String: Any], documentID: String) {
        guard let mood = dict["mood"] as? String,
              let note = dict["note"] as? String,
              let timestamp = dict["date"] as? Timestamp else {
            return nil
        }

        self.id = documentID
        self.mood = mood
        self.note = note
        self.date = timestamp.dateValue()
        self.goalIds = dict["goalIDs"] as? [String] ?? [] // ❗️Firestore'da key büyük I ile
    }

    static func == (lhs: MoodEntry, rhs: MoodEntry) -> Bool {
        return lhs.id == rhs.id &&
               lhs.mood == rhs.mood &&
               lhs.note == rhs.note &&
               lhs.date == rhs.date &&
               lhs.goalIds == rhs.goalIds
    }
}
