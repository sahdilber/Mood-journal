import Foundation
import FirebaseFirestore

struct MoodEntry: Identifiable, Equatable {
    let id: String
    let mood: String
    let note: String
    let date: Date

    // Firestore’a gönderilecek sözlük formatı
    var asDictionary: [String: Any] {
        return [
            "id": id,
            "mood": mood,
            "note": note,
            "date": Timestamp(date: date)
        ]
    }

    // Uygulama içi kullanım için initializer
    init(id: String = UUID().uuidString, mood: String, note: String, date: Date = Date()) {
        self.id = id
        self.mood = mood
        self.note = note
        self.date = date
    }

    // Firestore'dan gelen veriyle model oluşturma (✅ documentID ile)
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
    }

    // Equatable sadece id’ye göre karşılaştırır
    static func == (lhs: MoodEntry, rhs: MoodEntry) -> Bool {
        return lhs.id == rhs.id
    }
}
