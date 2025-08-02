import SwiftUI

struct CalendarView: View {
    let moodEntries: [MoodEntry]

    @State private var selectedDate = Date()
    @State private var currentMonthOffset = 0

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        let currentMonthDates = generateDatesForMonth(offset: currentMonthOffset)

        VStack(spacing: 16) {
            // 🔹 Ay Başlığı ve Oklar
            HStack {
                Button(action: { currentMonthOffset -= 1 }) {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(monthYearText(from: selectedDate))
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: { currentMonthOffset += 1 }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            // 🔹 Gün Başlıkları
            HStack {
                ForEach(["P", "S", "Ç", "P", "C", "C", "P"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }

            // 🔹 Takvim Günleri
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(currentMonthDates, id: \.self) { date in
                    let isPlaceholder = calendar.isDate(date, equalTo: Date.distantPast, toGranularity: .day)
                    let hasMood = moodEntries.contains { calendar.isDate($0.date, inSameDayAs: date) }
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

                    Button(action: {
                        if !isPlaceholder {
                            selectedDate = date
                        }
                    }) {
                        ZStack {
                            if !isPlaceholder {
                                Circle()
                                    .fill(hasMood ? Color.blue.opacity(isSelected ? 0.5 : 0.2) : .clear)
                                    .frame(width: 36, height: 36)

                                Text("\(calendar.component(.day, from: date))")
                                    .font(.body)
                                    .foregroundColor(isSelected ? .white : .primary)
                            } else {
                                Text("")
                                    .frame(width: 36, height: 36)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            Circle()
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .disabled(isPlaceholder)
                }
            }
            .padding(.bottom)

            Divider()

            // 🔹 Seçili Gün Mood Listesi
            let todaysMoods = moodEntries.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            if todaysMoods.isEmpty {
                Text("Bu gün için mood girişi yok.")
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            } else {
                List(todaysMoods) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(entry.mood)
                                .font(.title)
                            Spacer()
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        if !entry.note.isEmpty {
                            Text(entry.note)
                                .font(.body)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(height: 200)
                .listStyle(.plain)
            }
        }
        .padding()
        .onAppear {
            selectedDate = Date()
        }
    }

    // 🔹 Ay yılı başlığı
    func monthYearText(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMMM yyyy"
        let adjustedDate = calendar.date(byAdding: .month, value: currentMonthOffset, to: date) ?? date
        return formatter.string(from: adjustedDate).capitalized
    }

    // 🔹 Seçilen aya ait tüm tarihler (ve boşluklar)
    func generateDatesForMonth(offset: Int) -> [Date] {
        let now = calendar.date(byAdding: .month, value: offset, to: Date()) ?? Date()
        guard let monthInterval = calendar.dateInterval(of: .month, for: now) else {
            return []
        }

        let monthStart = monthInterval.start
        guard let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }

        var dates = daysInMonth.compactMap {
            calendar.date(byAdding: .day, value: $0 - 1, to: monthStart)
        }

        let weekday = calendar.component(.weekday, from: dates.first ?? Date())
        let leadingEmptyDays = weekday == 1 ? 6 : weekday - 2
        let prefix = (0..<leadingEmptyDays).map { _ in Date.distantPast }

        dates.insert(contentsOf: prefix, at: 0)
        return dates
    }
}
