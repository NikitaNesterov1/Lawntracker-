import CoreLocation
import SwiftUI

struct LawnIntelligenceView: View {
    @EnvironmentObject private var store: LawnStore
    @StateObject private var locationProvider = LocationProvider()

    @State private var locationQuery = ""
    @State private var locationResults: [LocationSearchResult] = []
    @State private var isSearchingLocation = false
    @State private var isRefreshingWeather = false
    @State private var statusMessage: String?

    private let weatherService = WeatherService()

    var body: some View {
        NavigationStack {
            List {
                locationSection
                weatherSection
                lawnBasicsSection
                lawnReadSection
            }
            .navigationTitle("Lawn Info")
            .toolbar {
                Button {
                    Task { await refreshWeather() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(!store.userProfile.hasCoordinate || isRefreshingWeather)
            }
            .onReceive(locationProvider.$lastLocation.compactMap { $0 }) { location in
                applyCurrentLocation(location)
            }
            .onReceive(locationProvider.$lastResolvedName.compactMap { $0 }) { resolvedName in
                store.userProfile.locationLabel = resolvedName
            }
        }
    }

    private var locationSection: some View {
        Section("Personal location") {
            LabeledContent("Saved place", value: store.userProfile.locationLabel)
            LabeledContent("Coordinates", value: store.userProfile.coordinateSummary)
            if let elevationFeet = store.userProfile.elevationFeet {
                LabeledContent("Elevation", value: "\(elevationFeet) ft")
            }
            LabeledContent("Permission", value: locationProvider.authorizationDescription)

            Button {
                locationProvider.requestUserLocation()
            } label: {
                Label(locationProvider.isLocating ? "Finding location..." : "Use Current Location", systemImage: "location")
            }
            .disabled(locationProvider.isLocating)

            HStack {
                TextField("Search city or ZIP", text: $locationQuery)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await searchLocations() }
                    }

                Button {
                    Task { await searchLocations() }
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .disabled(locationQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSearchingLocation)
            }

            ForEach(locationResults) { result in
                Button {
                    applySearchResult(result)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.displayName)
                        Text(String(format: "%.4f, %.4f", result.latitude, result.longitude))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let errorMessage = locationProvider.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if let statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var weatherSection: some View {
        Section("Weather and rainfall") {
            Button {
                Task { await refreshWeather() }
            } label: {
                Label(isRefreshingWeather ? "Refreshing weather..." : "Refresh Weather", systemImage: "cloud.sun.rain")
            }
            .disabled(!store.userProfile.hasCoordinate || isRefreshingWeather)

            if let snapshot = store.weatherSnapshot {
                if let current = snapshot.current {
                    LabeledContent("Temperature", value: current.temperatureF?.temperatureString ?? "Unknown")
                    LabeledContent("Humidity", value: current.humidityPercent?.percentString ?? "Unknown")
                    LabeledContent("Wind", value: current.windSpeedMph?.mphString ?? "Unknown")
                }

                LabeledContent("Past 7 days rain", value: snapshot.recentRainfallTotal.inchesString)
                LabeledContent("Next 7 days rain", value: snapshot.forecastRainfallTotal.inchesString)
                LabeledContent("Past 7 days ET", value: snapshot.recentEvapotranspirationTotal.inchesString)

                Text("Updated \(DateFormatter.lawnShortWithTime.string(from: snapshot.fetchedAt))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                DisclosureGroup("Recent daily totals") {
                    dailyRows(snapshot.recentDays)
                }

                DisclosureGroup("Forecast daily totals") {
                    dailyRows(snapshot.forecastDays)
                }
            } else {
                Text("Save a location, then refresh weather to load rainfall history and forecast estimates.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var lawnBasicsSection: some View {
        Section("Lawn basics") {
            TextField("Property name", text: binding(\.propertyName))

            Stepper(value: binding(\.lawnSizeSquareFeet), in: 0...200000, step: 100) {
                LabeledContent("Lawn size", value: "\(store.userProfile.lawnSizeSquareFeet) sq ft")
            }

            Stepper(value: binding(\.mowingHeightInches), in: 1.0...5.0, step: 0.25) {
                LabeledContent("Mowing height", value: store.userProfile.mowingHeightInches.inchesString)
            }

            Picker("Grass", selection: binding(\.grassType)) {
                ForEach(GrassType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }

            Picker("Soil", selection: binding(\.soilTexture)) {
                ForEach(SoilTexture.allCases) { texture in
                    Text(texture.rawValue).tag(texture)
                }
            }

            Picker("Slope", selection: binding(\.slope)) {
                ForEach(LawnSlope.allCases) { slope in
                    Text(slope.rawValue).tag(slope)
                }
            }

            Picker("Sun", selection: binding(\.sunExposure)) {
                ForEach(LawnSunExposure.allCases) { exposure in
                    Text(exposure.rawValue).tag(exposure)
                }
            }

            Picker("Watering", selection: binding(\.irrigationMethod)) {
                ForEach(IrrigationMethod.allCases) { method in
                    Text(method.rawValue).tag(method)
                }
            }

            TextField("Notes", text: binding(\.notes), axis: .vertical)
                .lineLimit(2...5)
        }
    }

    private var lawnReadSection: some View {
        Section("Lawn read") {
            let recommendation = LawnAdvisor.recommendation(
                sevenDayRainfall: store.weatherSnapshot?.recentRainfallTotal ?? store.sevenDayRainfall,
                sevenDayWaterEquivalent: store.sevenDayWaterEquivalent,
                lastWatering: store.lastWatering
            )

            Text(recommendation.title)
                .font(.headline)
            Text(recommendation.detail)
                .foregroundStyle(.secondary)

            if let snapshot = store.weatherSnapshot {
                let balance = snapshot.recentMoistureBalance
                LabeledContent("Moisture balance", value: balance.signedInchesString)
                Text(balance < -0.5 ? "Recent water loss is outpacing rainfall. Check soil moisture before adding irrigation." : "Recent rainfall and water loss are reasonably balanced.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Slope, soil, sun, grass type, rainfall, watering, and forecast will drive future recommendations.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func dailyRows(_ days: [DailyLawnWeather]) -> some View {
        ForEach(days) { day in
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(DateFormatter.lawnShort.string(from: day.date))
                    Spacer()
                    Text(day.precipitationInches.inchesString)
                        .font(.subheadline.weight(.semibold))
                }
                HStack {
                    if let low = day.lowF, let high = day.highF {
                        Text("\(low.temperatureString) - \(high.temperatureString)")
                    }
                    if let probability = day.precipitationProbabilityPercent {
                        Text("\(probability)% rain chance")
                    }
                    if let evapotranspiration = day.evapotranspirationInches {
                        Text("ET \(evapotranspiration.inchesString)")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        }
    }

    private func searchLocations() async {
        isSearchingLocation = true
        statusMessage = nil
        defer { isSearchingLocation = false }

        do {
            locationResults = try await weatherService.searchLocations(matching: locationQuery)
        } catch {
            locationResults = []
            statusMessage = error.localizedDescription
        }
    }

    private func refreshWeather() async {
        isRefreshingWeather = true
        statusMessage = nil
        defer { isRefreshingWeather = false }

        do {
            store.weatherSnapshot = try await weatherService.fetchWeather(for: store.userProfile)
            statusMessage = "Weather updated."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func applyCurrentLocation(_ location: CLLocation) {
        store.userProfile.latitude = location.coordinate.latitude
        store.userProfile.longitude = location.coordinate.longitude
        store.userProfile.elevationFeet = Int((location.altitude * 3.28084).rounded())
        if store.userProfile.locationLabel.isEmpty {
            store.userProfile.locationLabel = "Current location"
        }
        Task { await refreshWeather() }
    }

    private func applySearchResult(_ result: LocationSearchResult) {
        store.userProfile.locationLabel = result.displayName
        store.userProfile.latitude = result.latitude
        store.userProfile.longitude = result.longitude
        store.userProfile.elevationFeet = result.elevationFeet
        locationResults = []
        locationQuery = result.displayName
        Task { await refreshWeather() }
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<UserLawnProfile, Value>) -> Binding<Value> {
        Binding {
            store.userProfile[keyPath: keyPath]
        } set: { newValue in
            store.userProfile[keyPath: keyPath] = newValue
        }
    }
}

private extension DateFormatter {
    static let lawnShortWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

private extension Double {
    var temperatureString: String {
        String(format: "%.0f F", self)
    }

    var percentString: String {
        String(format: "%.0f%%", self)
    }

    var mphString: String {
        String(format: "%.0f mph", self)
    }

    var signedInchesString: String {
        String(format: "%+.2f in", self)
    }
}
