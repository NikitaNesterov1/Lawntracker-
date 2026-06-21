import Foundation

struct UserLawnProfile: Codable, Equatable {
    var propertyName: String
    var locationLabel: String
    var latitude: Double?
    var longitude: Double?
    var elevationFeet: Int?
    var lawnSizeSquareFeet: Int
    var grassType: GrassType
    var soilTexture: SoilTexture
    var slope: LawnSlope
    var sunExposure: LawnSunExposure
    var irrigationMethod: IrrigationMethod
    var mowingHeightInches: Double
    var notes: String

    static let bushkillSample = UserLawnProfile(
        propertyName: "Home lawn",
        locationLabel: "Bushkill / Saw Creek, PA",
        latitude: nil,
        longitude: nil,
        elevationFeet: 974,
        lawnSizeSquareFeet: 5000,
        grassType: .coolSeasonMix,
        soilTexture: .stonyThin,
        slope: .sloped,
        sunExposure: .mixed,
        irrigationMethod: .manual,
        mowingHeightInches: 3.5,
        notes: "Summer survival first. Keep grass tall, avoid scalping, and confirm rainfall with a gauge when possible."
    )

    var hasCoordinate: Bool {
        latitude != nil && longitude != nil
    }

    var coordinateSummary: String {
        guard let latitude, let longitude else {
            return "No coordinates saved"
        }
        return String(format: "%.4f, %.4f", latitude, longitude)
    }
}

enum GrassType: String, Codable, CaseIterable, Identifiable {
    case unknown = "Unknown"
    case coolSeasonMix = "Cool-season mix"
    case kentuckyBluegrass = "Kentucky bluegrass"
    case tallFescue = "Tall fescue"
    case perennialRye = "Perennial ryegrass"
    case fineFescue = "Fine fescue"
    case warmSeason = "Warm-season grass"

    var id: String { rawValue }
}

enum SoilTexture: String, Codable, CaseIterable, Identifiable {
    case unknown = "Unknown"
    case sandy = "Sandy"
    case loam = "Loam"
    case clay = "Clay"
    case rocky = "Rocky"
    case stonyThin = "Stony / thin"
    case compacted = "Compacted"

    var id: String { rawValue }
}

enum LawnSlope: String, Codable, CaseIterable, Identifiable {
    case flat = "Flat"
    case gentle = "Gentle slope"
    case sloped = "Sloped"
    case steep = "Steep slope"
    case mixed = "Mixed terrain"

    var id: String { rawValue }
}

enum LawnSunExposure: String, Codable, CaseIterable, Identifiable {
    case fullSun = "Full sun"
    case mostlySun = "Mostly sun"
    case mixed = "Mixed sun and shade"
    case mostlyShade = "Mostly shade"
    case fullShade = "Full shade"

    var id: String { rawValue }
}

enum IrrigationMethod: String, Codable, CaseIterable, Identifiable {
    case none = "No irrigation"
    case manual = "Manual sprinkler"
    case hose = "Hose watering"
    case inGround = "In-ground system"
    case drip = "Drip / soaker"

    var id: String { rawValue }
}
