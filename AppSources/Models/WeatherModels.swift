import Foundation

struct LawnWeatherSnapshot: Codable, Equatable {
    var fetchedAt: Date
    var latitude: Double
    var longitude: Double
    var locationName: String
    var timezone: String
    var current: CurrentLawnWeather?
    var recentDays: [DailyLawnWeather]
    var forecastDays: [DailyLawnWeather]

    var recentRainfallTotal: Double {
        recentDays.map(\.precipitationInches).reduce(0, +)
    }

    var forecastRainfallTotal: Double {
        forecastDays.map(\.precipitationInches).reduce(0, +)
    }

    var recentEvapotranspirationTotal: Double {
        recentDays.compactMap(\.evapotranspirationInches).reduce(0, +)
    }

    var forecastEvapotranspirationTotal: Double {
        forecastDays.compactMap(\.evapotranspirationInches).reduce(0, +)
    }

    var recentMoistureBalance: Double {
        recentRainfallTotal - recentEvapotranspirationTotal
    }

    var todayForecast: DailyLawnWeather? {
        let today = Calendar.current.startOfDay(for: Date())
        return forecastDays.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    var nextThreeDayRainfallTotal: Double {
        forecastDays.prefix(3).map(\.precipitationInches).reduce(0, +)
    }

    var highestRainChanceDay: DailyLawnWeather? {
        forecastDays.max {
            ($0.precipitationProbabilityPercent ?? 0) < ($1.precipitationProbabilityPercent ?? 0)
        }
    }
}

struct LawnRainfallSummary: Equatable {
    var confirmedLastSevenDays: Double
    var confirmedWeekToDate: Double
    var weatherEstimatedPreviousSevenDays: Double?
    var predictedNextSevenDays: Double?
    var predictedNextThreeDays: Double?
    var wateringLastSevenDays: Double

    var bestObservedRainfall: Double {
        if confirmedLastSevenDays > 0 {
            return confirmedLastSevenDays
        }
        return weatherEstimatedPreviousSevenDays ?? 0
    }

    var observedSourceLabel: String {
        confirmedLastSevenDays > 0 ? "Using logged rainfall" : "Using weather estimate"
    }

    var observedWaterTotal: Double {
        bestObservedRainfall + wateringLastSevenDays
    }
}

struct CurrentLawnWeather: Codable, Equatable {
    var observedAt: Date?
    var temperatureF: Double?
    var humidityPercent: Double?
    var precipitationInches: Double?
    var rainInches: Double?
    var windSpeedMph: Double?
    var weatherCode: Int?
}

struct DailyLawnWeather: Identifiable, Codable, Equatable {
    var id: Date { date }

    var date: Date
    var precipitationInches: Double
    var rainInches: Double
    var evapotranspirationInches: Double?
    var highF: Double?
    var lowF: Double?
    var precipitationProbabilityPercent: Int?
}

struct LocationSearchResult: Identifiable, Codable, Equatable {
    var id: Int
    var name: String
    var admin1: String?
    var countryCode: String?
    var latitude: Double
    var longitude: Double
    var elevationMeters: Double?
    var timezone: String?

    var displayName: String {
        [name, admin1, countryCode].compactMap { value in
            guard let value = value, !value.isEmpty else { return nil }
            return value
        }
        .joined(separator: ", ")
    }

    var elevationFeet: Int? {
        guard let elevationMeters = elevationMeters else { return nil }
        return Int((elevationMeters * 3.28084).rounded())
    }
}
