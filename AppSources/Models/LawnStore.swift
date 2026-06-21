import Foundation
import Combine

@MainActor
final class LawnStore: ObservableObject {
    @Published var profile: LawnProfile {
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
            self.rainfallEntries = snapshot.rainfallEntries
            self.wateringEntries = snapshot.wateringEntries
            self.workEntries = snapshot.workEntries
            self.plants = snapshot.plants
            self.seasonalTasks = snapshot.seasonalTasks
        } else {
            self.profile = .bushkill
            self.rainfallEntries = SampleData.rainfallEntries
            self.wateringEntries = SampleData.wateringEntries
            self.workEntries = SampleData.workEntries
            self.plants = SampleData.plants
            self.seasonalTasks = SampleData.seasonalTasks
        }
    }

    func resetToSampleData() {
        profile = .bushkill
        rainfallEntries = SampleData.rainfallEntries
        wateringEntries = SampleData.wateringEntries
        workEntries = SampleData.workEntries
        plants = SampleData.plants
        seasonalTasks = SampleData.seasonalTasks
    }

    var sevenDayRainfall: Double {
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return rainfallEntries
            .filter { $0.date >= start }
            .map(\.amountInches)
            .reduce(0, +)
    }

    var sevenDayWaterEquivalent: Double {
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return wateringEntries
            .filter { $0.date >= start }
            .map(\.estimatedInches)
            .reduce(0, +)
    }

    var lastRainfall: RainfallEntry? {
        rainfallEntries.sorted { $0.date > $1.date }.first
    }

    var lastWatering: WateringEntry? {
        wateringEntries.sorted { $0.date > $1.date }.first
    }

    private func save() {
        let snapshot = LawnStoreSnapshot(
            profile: profile,
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
