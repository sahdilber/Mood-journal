import Foundation

struct MoodGoal: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var emoji: String
    var createdAt: Date
    var completedDates: [Date]      // Tamamlanan günler
    var targetCount: Int            // Kaç gün hedefleniyor

    init(
        id: String = UUID().uuidString,
        title: String,
        emoji: String,
        createdAt: Date = Date(),
        completedDates: [Date] = [],
        targetCount: Int = 30
    ) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.createdAt = createdAt
        self.completedDates = completedDates
        self.targetCount = targetCount
    }

    var asDictionary: [String: Any] {
        return [
            "id": id,
            "title": title,
            "emoji": emoji,
            "createdAt": createdAt.timeIntervalSince1970,
            "completedDates": completedDates.map { $0.timeIntervalSince1970 },
            "targetCount": targetCount
        ]
    }

    init?(from dict: [String: Any]) {
        guard
            let id = dict["id"] as? String,
            let title = dict["title"] as? String,
            let emoji = dict["emoji"] as? String,
            let timestamp = dict["createdAt"] as? TimeInterval,
            let completedTimestamps = dict["completedDates"] as? [TimeInterval],
            let targetCount = dict["targetCount"] as? Int
        else {
            return nil
        }

        self.id = id
        self.title = title
        self.emoji = emoji
        self.createdAt = Date(timeIntervalSince1970: timestamp)
        self.completedDates = completedTimestamps.map { Date(timeIntervalSince1970: $0) }
        self.targetCount = targetCount
    }

    // 🔢 Benzersiz gün sayısı
    var uniqueDaysCount: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(completedDates.map { calendar.startOfDay(for: $0) })
        return uniqueDays.count
    }

    // 🔢 İlerleme yüzdesi
    var completionRate: Double {
        Double(uniqueDaysCount) / Double(targetCount)
    }

    // 🎯 Hedef tamamlandı mı?
    var isCompleted: Bool {
        uniqueDaysCount >= targetCount
    }

    // ➕ Yeni gün ekle (aynı gün eklenmesin)
    mutating func addCompletion(for date: Date) {
        let calendar = Calendar.current
        let newDay = calendar.startOfDay(for: date)
        let days = completedDates.map { calendar.startOfDay(for: $0) }
        if !days.contains(newDay) {
            completedDates.append(date)
        }
    }
}
