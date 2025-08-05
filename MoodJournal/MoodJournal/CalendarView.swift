import SwiftUI

struct CalendarView: View {
    let moodEntries: [MoodEntry]

    @State private var selectedDate = Date()
    @State private var currentMonthOffset = 0

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        let currentMonthDates = generateDatesForMonth(offset: currentMonthOffset)

        ZStack {
            // 🌌 Arka plan (LoginView'daki gibi)
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                // 🔹 Ay Başlığı ve Oklar
                HStack {
                    Button(action: { currentMonthOffset -= 1 }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text(monthYearText(from: selectedDate))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: { currentMonthOffset += 1 }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
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
                            .foregroundColor(.white.opacity(0.6))
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
                                    if hasMood {
                                        Circle()
                                            .fill(LinearGradient(
                                                colors: [
                                                    Color.blue.opacity(isSelected ? 0.8 : 0.3),
                                                    Color.purple.opacity(isSelected ? 0.8 : 0.3)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ))
                                            .frame(width: 38, height: 38)
                                    }

                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.body)
                                        .foregroundColor(isSelected ? .white : .white.opacity(0.9))
                                        .frame(width: 36, height: 36)
                                }
                            }
                            .background(
                                Circle()
                                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                            )
                        }
                        .disabled(isPlaceholder)
                    }
                }
                .padding(.bottom)

                Divider()
                    .background(Color.white.opacity(0.3))

                // 🔹 Seçili Gün Mood Listesi
                let todaysMoods = moodEntries.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
                if todaysMoods.isEmpty {
                    Text("Bu gün için mood girişi yok.")
                        .foregroundColor(.white.opacity(0.7))
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
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            if !entry.note.isEmpty {
                                Text(entry.note)
                                    .foregroundColor(.white)
                                    .font(.body)
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.black.opacity(0.2))
                    }
                    .frame(height: 200)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .padding()
        }
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
