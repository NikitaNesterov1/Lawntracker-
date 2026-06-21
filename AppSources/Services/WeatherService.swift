import Foundation

enum WeatherServiceError: LocalizedError {
    case missingCoordinate
    case invalidURL
    case requestFailed(Int)
    case emptyLocationSearch

    var errorDescription: String? {
        switch self {
        case .missingCoordinate:
            return "Save a location before refreshing weather."
        case .invalidURL:
            return "The weather request could not be built."
        case .requestFailed(let statusCode):
            return "The weather service returned status \(statusCode)."
        case .emptyLocationSearch:
            return "No matching location was found."
        }
    }
}

struct WeatherService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchWeather(for profile: UserLawnProfile) async throws -> LawnWeatherSnapshot {
        guard let latitude = profile.latitude, let longitude = profile.longitude else {
            throw WeatherServiceError.missingCoordinate
        }

        let response: OpenMeteoForecastResponse = try await fetchJSON(from: forecastURL(latitude: latitude, longitude: longitude))
        let responseTimeZone: TimeZone
        if let timezone = response.timezone,
           let resolvedTimeZone = TimeZone(identifier: timezone) {
            responseTimeZone = resolvedTimeZone
        } else {
            responseTimeZone = .current
        }
        let dailyRows = dailyWeatherRows(from: response.daily, timeZone: responseTimeZone)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = responseTimeZone
        let today = calendar.startOfDay(for: Date())
        let recentDays = dailyRows
            .filter { $0.date < today }
            .suffix(7)
        let forecastDays = dailyRows
            .filter { $0.date >= today }
            .prefix(7)

        return LawnWeatherSnapshot(
            fetchedAt: Date(),
            latitude: response.latitude,
            longitude: response.longitude,
            locationName: profile.locationLabel,
            timezone: response.timezone ?? "auto",
            current: currentWeather(from: response.current),
            recentDays: Array(recentDays),
            forecastDays: Array(forecastDays)
        )
    }

    func searchLocations(matching query: String) async throws -> [LocationSearchResult] {
        let cleanedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedQuery.isEmpty else { return [] }

        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "name", value: cleanedQuery),
            URLQueryItem(name: "count", value: "8"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "countryCode", value: "US")
        ]

        guard let url = components?.url else {
            throw WeatherServiceError.invalidURL
        }

        let response: OpenMeteoGeocodingResponse = try await fetchJSON(from: url)
        guard let results = response.results, !results.isEmpty else {
            throw WeatherServiceError.emptyLocationSearch
        }

        return results.map {
            LocationSearchResult(
                id: $0.id,
                name: $0.name,
                admin1: $0.admin1,
                countryCode: $0.country_code,
                latitude: $0.latitude,
                longitude: $0.longitude,
                elevationMeters: $0.elevation,
                timezone: $0.timezone
            )
        }
    }

    private func forecastURL(latitude: Double, longitude: Double) throws -> URL {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,precipitation,rain,weather_code,wind_speed_10m"),
            URLQueryItem(name: "daily", value: "precipitation_sum,rain_sum,temperature_2m_max,temperature_2m_min,et0_fao_evapotranspiration,precipitation_probability_max"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "wind_speed_unit", value: "mph"),
            URLQueryItem(name: "precipitation_unit", value: "inch"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "past_days", value: "7"),
            URLQueryItem(name: "forecast_days", value: "7")
        ]

        guard let url = components?.url else {
            throw WeatherServiceError.invalidURL
        }
        return url
    }

    private func fetchJSON<Response: Decodable>(from url: URL) async throws -> Response {
        let (data, urlResponse) = try await session.data(from: url)
        if let httpResponse = urlResponse as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw WeatherServiceError.requestFailed(httpResponse.statusCode)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }

    private func currentWeather(from current: OpenMeteoCurrentWeather?) -> CurrentLawnWeather? {
        guard let current = current else { return nil }
        return CurrentLawnWeather(
            observedAt: current.time.flatMap { Self.dayAndMinuteFormatter.date(from: $0) },
            temperatureF: current.temperature_2m,
            humidityPercent: current.relative_humidity_2m,
            precipitationInches: current.precipitation,
            rainInches: current.rain,
            windSpeedMph: current.wind_speed_10m,
            weatherCode: current.weather_code
        )
    }

    private func dailyWeatherRows(from daily: OpenMeteoDailyWeather?, timeZone: TimeZone) -> [DailyLawnWeather] {
        guard let daily = daily else { return [] }
        let formatter = Self.dayFormatter(timeZone: timeZone)
        return daily.time.enumerated().compactMap { index, dayString in
            guard let date = formatter.date(from: dayString) else { return nil }
            return DailyLawnWeather(
                date: date,
                precipitationInches: daily.precipitation_sum[safe: index] ?? 0,
                rainInches: daily.rain_sum?[safe: index] ?? 0,
                evapotranspirationInches: daily.et0_fao_evapotranspiration?[safe: index],
                highF: daily.temperature_2m_max?[safe: index],
                lowF: daily.temperature_2m_min?[safe: index],
                precipitationProbabilityPercent: daily.precipitation_probability_max?[safe: index]
            )
        }
    }

    private static func dayFormatter(timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    private static let dayAndMinuteFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return formatter
    }()
}

private struct OpenMeteoForecastResponse: Decodable {
    var latitude: Double
    var longitude: Double
    var timezone: String?
    var current: OpenMeteoCurrentWeather?
    var daily: OpenMeteoDailyWeather?
}

private struct OpenMeteoCurrentWeather: Decodable {
    var time: String?
    var temperature_2m: Double?
    var relative_humidity_2m: Double?
    var precipitation: Double?
    var rain: Double?
    var weather_code: Int?
    var wind_speed_10m: Double?
}

private struct OpenMeteoDailyWeather: Decodable {
    var time: [String]
    var precipitation_sum: [Double]
    var rain_sum: [Double]?
    var temperature_2m_max: [Double]?
    var temperature_2m_min: [Double]?
    var et0_fao_evapotranspiration: [Double]?
    var precipitation_probability_max: [Int]?
}

private struct OpenMeteoGeocodingResponse: Decodable {
    var results: [OpenMeteoLocationResult]?
}

private struct OpenMeteoLocationResult: Decodable {
    var id: Int
    var name: String
    var latitude: Double
    var longitude: Double
    var elevation: Double?
    var timezone: String?
    var country_code: String?
    var admin1: String?
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
