import Foundation

struct RainfallEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var date: Date
    var amountInches: Double
    var source: RainfallSource
    var notes: String

    init(id: UUID = UUID(), date: Date, amountInches: Double, source: RainfallSource, notes: String = "") {
        self.id = id
        self.date = date
        self.amountInches = amountInches
        self.source = source
        self.notes = notes
    }
}

enum RainfallSource: String, Codable, CaseIterable, Identifiable {
    case rainGauge = "Rain gauge"
    case weatherEstimate = "Weather estimate"
    case nwsNoaa = "NWS / NOAA"
    case manualObservation = "Manual observation"

    var id: String { rawValue }
}

struct WateringEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var date: Date
    var durationMinutes: Int
    var zone: String
    var estimatedInches: Double
    var notes: String

    init(id: UUID = UUID(), date: Date, durationMinutes: Int, zone: String, estimatedInches: Double, notes: String = "") {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.zone = zone
        self.estimatedInches = estimatedInches
        self.notes = notes
    }
}

struct WorkEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var date: Date
    var type: WorkType
    var area: String
    var notes: String

    init(id: UUID = UUID(), date: Date, type: WorkType, area: String, notes: String = "") {
        self.id = id
        self.date = date
        self.type = type
        self.area = area
        self.notes = notes
    }
}

enum WorkType: String, Codable, CaseIterable, Identifiable {
    case mowing = "Mowing"
    case trimming = "Trimming"
    case seeding = "Seeding"
    case fertilizer = "Fertilizer"
    case soilWork = "Soil work"
    case observation = "Observation"

    var id: String { rawValue }
}

struct PlantItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var location: String
    var plantedDate: Date?
    var status: PlantStatus
    var notes: String
}

enum PlantStatus: String, Codable, CaseIterable, Identifiable {
    case thriving = "Thriving"
    case monitoring = "Monitoring"
    case stressed = "Stressed"
    case dormant = "Dormant"
    case unknown = "Unknown"

    var id: String { rawValue }
}

struct SeasonalTask: Identifiable, Codable, Equatable {
    var id = UUID()
    var season: String
    var window: String
    var title: String
    var details: String
    var priority: TaskPriority
}

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    var id: String { rawValue }
}
