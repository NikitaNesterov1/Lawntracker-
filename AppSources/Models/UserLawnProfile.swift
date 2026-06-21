import Foundation

struct UserLawnProfile: Codable, Equatable {
    var propertyName: String
    var locationLabel: String
    var latitude: Double?
    var longitude: Double?
    var elevationFeet: Int?
    var lawnSizeSquareFeet: Int
    var lawnGoal: LawnGoal
    var grassType: GrassType
    var soilTexture: SoilTexture
    var slope: LawnSlope
    var sunExposure: LawnSunExposure
    var irrigationMethod: IrrigationMethod
    var mowingHeightInches: Double
    var notes: String
    var onboardingCompletedAt: Date?

    private enum CodingKeys: String, CodingKey {
        case propertyName
        case locationLabel
        case latitude
        case longitude
        case elevationFeet
        case lawnSizeSquareFeet
        case lawnGoal
        case grassType
        case soilTexture
        case slope
        case sunExposure
        case irrigationMethod
        case mowingHeightInches
        case notes
        case onboardingCompletedAt
    }

    static let bushkillSample = UserLawnProfile(
        propertyName: "Home lawn",
        locationLabel: "Bushkill / Saw Creek, PA",
        latitude: nil,
        longitude: nil,
        elevationFeet: 974,
        lawnSizeSquareFeet: 5000,
        lawnGoal: .healthyDense,
        grassType: .coolSeasonMix,
        soilTexture: .stonyThin,
        slope: .sloped,
        sunExposure: .mixed,
        irrigationMethod: .manual,
        mowingHeightInches: 3.5,
        notes: "Summer survival first. Keep grass tall, avoid scalping, and confirm rainfall with a gauge when possible.",
        onboardingCompletedAt: nil
    )

    init(
        propertyName: String,
        locationLabel: String,
        latitude: Double?,
        longitude: Double?,
        elevationFeet: Int?,
        lawnSizeSquareFeet: Int,
        lawnGoal: LawnGoal,
        grassType: GrassType,
        soilTexture: SoilTexture,
        slope: LawnSlope,
        sunExposure: LawnSunExposure,
        irrigationMethod: IrrigationMethod,
        mowingHeightInches: Double,
        notes: String,
        onboardingCompletedAt: Date? = nil
    ) {
        self.propertyName = propertyName
        self.locationLabel = locationLabel
        self.latitude = latitude
        self.longitude = longitude
        self.elevationFeet = elevationFeet
        self.lawnSizeSquareFeet = lawnSizeSquareFeet
        self.lawnGoal = lawnGoal
        self.grassType = grassType
        self.soilTexture = soilTexture
        self.slope = slope
        self.sunExposure = sunExposure
        self.irrigationMethod = irrigationMethod
        self.mowingHeightInches = mowingHeightInches
        self.notes = notes
        self.onboardingCompletedAt = onboardingCompletedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        propertyName = try container.decodeIfPresent(String.self, forKey: .propertyName) ?? "Home lawn"
        locationLabel = try container.decodeIfPresent(String.self, forKey: .locationLabel) ?? "Unknown location"
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        elevationFeet = try container.decodeIfPresent(Int.self, forKey: .elevationFeet)
        lawnSizeSquareFeet = try container.decodeIfPresent(Int.self, forKey: .lawnSizeSquareFeet) ?? 5000
        lawnGoal = try container.decodeIfPresent(LawnGoal.self, forKey: .lawnGoal) ?? .healthyDense
        grassType = try container.decodeIfPresent(GrassType.self, forKey: .grassType) ?? .coolSeasonMix
        soilTexture = try container.decodeIfPresent(SoilTexture.self, forKey: .soilTexture) ?? .unknown
        slope = try container.decodeIfPresent(LawnSlope.self, forKey: .slope) ?? .mixed
        sunExposure = try container.decodeIfPresent(LawnSunExposure.self, forKey: .sunExposure) ?? .mixed
        irrigationMethod = try container.decodeIfPresent(IrrigationMethod.self, forKey: .irrigationMethod) ?? .manual
        mowingHeightInches = try container.decodeIfPresent(Double.self, forKey: .mowingHeightInches) ?? 3.5
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        onboardingCompletedAt = try container.decodeIfPresent(Date.self, forKey: .onboardingCompletedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(propertyName, forKey: .propertyName)
        try container.encode(locationLabel, forKey: .locationLabel)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encodeIfPresent(elevationFeet, forKey: .elevationFeet)
        try container.encode(lawnSizeSquareFeet, forKey: .lawnSizeSquareFeet)
        try container.encode(lawnGoal, forKey: .lawnGoal)
        try container.encode(grassType, forKey: .grassType)
        try container.encode(soilTexture, forKey: .soilTexture)
        try container.encode(slope, forKey: .slope)
        try container.encode(sunExposure, forKey: .sunExposure)
        try container.encode(irrigationMethod, forKey: .irrigationMethod)
        try container.encode(mowingHeightInches, forKey: .mowingHeightInches)
        try container.encode(notes, forKey: .notes)
        try container.encodeIfPresent(onboardingCompletedAt, forKey: .onboardingCompletedAt)
    }

    var isOnboardingComplete: Bool {
        onboardingCompletedAt != nil
    }

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

enum LawnGoal: String, Codable, CaseIterable, Identifiable {
    case healthyDense = "Healthy, dense lawn"
    case droughtResilient = "Drought resilience"
    case repairBareSpots = "Repair bare spots"
    case lowMaintenance = "Low maintenance"
    case renovation = "Fall renovation"
    case curbAppeal = "Curb appeal"

    var id: String { rawValue }
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
