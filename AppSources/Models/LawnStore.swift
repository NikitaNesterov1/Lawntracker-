import Foundation
import Combine

@MainActor
final class LawnStore: ObservableObject {
    @Published var profile: LawnProfile {
        didSet { save() }
    }

    @Published var userProfile: UserLawnProfile {
        didSet { save() }
    }

    @Published var weatherSnapshot: LawnWeatherSnapshot? {
        didSet { save() }
    }

    @Published var rainfallEntries: [RainfallEntry] {
        didSet { save() }
    }

    @Published var wateringEntries: [WateringEntry] {
        didSet { save() }
    }

    @Published var workEntries: [WorkEntry] {
        didSet { save() }
    }

    @Published var plants: [PlantItem] {
        didSet { save() }
    }

    @Published var seasonalTasks: [SeasonalTask] {
        didSet { save() }
    }

    private let storageKey = "BushkillLawnTracker.Store.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let snapshot = try? JSONDecoder.lawnDecoder.decode(LawnStoreSnapshot.self, from: data) {
            self.profile = snapshot.profile
            self.userProfile = snapshot.userProfile ?? .bushkillSample
            self.weatherSnapshot = snapshot.weatherSnapshot
            self.rainfallEntries = snapshot.rainfallEntries
            self.wateringEntries = snapshot.wateringEntries
            self.workEntries = snapshot.workEntries
            self.plants = snapshot.plants
            self.seasonalTasks = snapshot.seasonalTasks
        } else {
            self.profile = .bushkill
            self.userProfile = .bushkillSample
            self.weatherSnapshot = nil
            self.rainfallEntries = SampleData.rainfallEntries
            self.wateringEntries = SampleData.wateringEntries
            self.workEntries = SampleData.workEntries
            self.plants = SampleData.plants
            self.seasonalTasks = SampleData.seasonalTasks
        }
    }

    func resetToSampleData() {
        profile = .bushkill
        userProfile = .bushkillSample
        weatherSnapshot = nil
        rainfallEntries = SampleData.rainfallEntries
        wateringEntries = SampleData.wateringEntries
        workEntries = SampleData.workEntries
        plants = SampleData.plants
        seasonalTasks = SampleData.seasonalTasks
    }

    var sevenDayRainfall: Double {
        rainfallTotal(in: lastSevenCalendarDaysInterval)
    }

    var sevenDayWaterEquivalent: Double {
        wateringTotal(in: lastSevenCalendarDaysInterval)
    }

    var currentWeekRainfall: Double {
        rainfallTotal(in: currentWeekInterval)
    }

    var rainfallSummary: LawnRainfallSummary {
        LawnRainfallSummary(
            confirmedLastSevenDays: sevenDayRainfall,
            confirmedWeekToDate: currentWeekRainfall,
            weatherEstimatedPreviousSevenDays: weatherSnapshot?.recentRainfallTotal,
            predictedNextSevenDays: weatherSnapshot?.forecastRainfallTotal,
            predictedNextThreeDays: weatherSnapshot?.nextThreeDayRainfallTotal,
            wateringLastSevenDays: sevenDayWaterEquivalent
        )
    }

    var lastRainfall: RainfallEntry? {
        rainfallEntries.sorted { $0.date > $1.date }.first
    }

    var lastWatering: WateringEntry? {
        wateringEntries.sorted { $0.date > $1.date }.first
    }

    private var lastSevenCalendarDaysInterval: DateInterval {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -6, to: todayStart) ?? todayStart
        let end = calendar.date(byAdding: .day, value: 1, to: todayStart) ?? Date()
        return DateInterval(start: start, end: end)
    }

    private var currentWeekInterval: DateInterval {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        let start = calendar.date(from: components) ?? calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
        return DateInterval(start: start, end: end)
    }

    private func rainfallTotal(in interval: DateInterval) -> Double {
        rainfallEntries
            .filter { interval.contains($0.date) }
            .map(\.amountInches)
            .reduce(0, +)
    }

    private func wateringTotal(in interval: DateInterval) -> Double {
        wateringEntries
            .filter { interval.contains($0.date) }
            .map(\.estimatedInches)
            .reduce(0, +)
    }

    private func save() {
        let snapshot = LawnStoreSnapshot(
            profile: profile,
            userProfile: userProfile,
            weatherSnapshot: weatherSnapshot,
            rainfallEntries: rainfallEntries,
            wateringEntries: wateringEntries,
            workEntries: workEntries,
            plants: plants,
            seasonalTasks: seasonalTasks
        )
        if let data = try? JSONEncoder.lawnEncoder.encode(snapshot) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

private struct LawnStoreSnapshot: Codable {
    var profile: LawnProfile
    var userProfile: UserLawnProfile?
    var weatherSnapshot: LawnWeatherSnapshot?
    var rainfallEntries: [RainfallEntry]
    var wateringEntries: [WateringEntry]
    var workEntries: [WorkEntry]
    var plants: [PlantItem]
    var seasonalTasks: [SeasonalTask]
}

extension JSONEncoder {
    static var lawnEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

extension JSONDecoder {
    static var lawnDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
