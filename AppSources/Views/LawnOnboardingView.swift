import CoreLocation
import SwiftUI

struct LawnOnboardingView: View {
    @EnvironmentObject private var store: LawnStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var locationProvider = LocationProvider()
    @State private var draft = UserLawnProfile.bushkillSample
    @State private var step = 0
    @State private var locationQuery = ""
    @State private var locationResults: [LocationSearchResult] = []
    @State private var isSearchingLocation = false
    @State private var statusMessage: String?

    private let weatherService = WeatherService()
    private let stepCount = 4

    var body: some View {
        NavigationStack {
            Form {
                progressSection

                currentStep
            }
            .navigationTitle("Lawn Setup")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        finish(markComplete: false)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(step == stepCount - 1 ? "Finish" : "Next") {
                        advance()
                    }
                }
            }
            .onAppear {
                draft = store.userProfile
            }
            .onReceive(locationProvider.$lastLocation.compactMap { $0 }) { location in
                applyCurrentLocation(location)
            }
            .onReceive(locationProvider.$lastResolvedName.compactMap { $0 }) { resolvedName in
                draft.locationLabel = resolvedName
            }
        }
    }

    private var progressSection: some View {
        Section {
            HStack {
                ForEach(0..<stepCount, id: \.self) { index in
                    Capsule()
                        .fill(index <= step ? Color.accentColor : Color.secondary.opacity(0.25))
                        .frame(height: 6)
                }
            }
            Text(stepTitle)
                .font(.headline)
        }
    }

    private var identityStep: some View {
        Section("Lawn identity") {
            TextField("Property name", text: binding(\.propertyName))

            Picker("Goal", selection: binding(\.lawnGoal)) {
                ForEach(LawnGoal.allCases) { goal in
                    Text(goal.rawValue).tag(goal)
                }
            }

            Stepper(value: binding(\.lawnSizeSquareFeet), in: 0...200000, step: 100) {
                LabeledContent("Size", value: "\(draft.lawnSizeSquareFeet) sq ft")
            }
        }
    }

    private var locationStep: some View {
        Section("Location") {
            LabeledContent("Saved place", value: draft.locationLabel)
            LabeledContent("Coordinates", value: draft.coordinateSummary)
            if let elevationFeet = draft.elevationFeet {
                LabeledContent("Elevation", value: "\(elevationFeet) ft")
            }

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

            if let statusMessage = statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var currentStep: some View {
        switch step {
        case 0:
            identityStep
        case 1:
            locationStep
        case 2:
            lawnDetailsStep
        default:
            careSetupStep
        }
    }

    private var lawnDetailsStep: some View {
        Section("Growing conditions") {
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
        }
    }

    private var careSetupStep: some View {
        Section("Care setup") {
            Picker("Watering", selection: binding(\.irrigationMethod)) {
                ForEach(IrrigationMethod.allCases) { method in
                    Text(method.rawValue).tag(method)
                }
            }

            Stepper(value: binding(\.mowingHeightInches), in: 1.0...5.0, step: 0.25) {
                LabeledContent("Mowing height", value: draft.mowingHeightInches.inchesString)
            }

            TextField("Notes", text: binding(\.notes), axis: .vertical)
                .lineLimit(2...5)
        }
    }

    private var stepTitle: String {
        switch step {
        case 0: return "Name the lawn and goal"
        case 1: return "Set the local weather point"
        case 2: return "Describe growing conditions"
        default: return "Set care preferences"
        }
    }

    private func advance() {
        if step < stepCount - 1 {
            step += 1
        } else {
            finish(markComplete: true)
        }
    }

    private func finish(markComplete: Bool) {
        if markComplete {
            draft.onboardingCompletedAt = Date()
        }

        let finishedProfile = draft
        store.userProfile = finishedProfile

        if finishedProfile.hasCoordinate {
            Task {
                if let snapshot = try? await weatherService.fetchWeather(for: finishedProfile) {
                    await MainActor.run {
                        store.weatherSnapshot = snapshot
                    }
                }
            }
        }

        dismiss()
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

    private func applyCurrentLocation(_ location: CLLocation) {
        draft.latitude = location.coordinate.latitude
        draft.longitude = location.coordinate.longitude
        draft.elevationFeet = Int((location.altitude * 3.28084).rounded())
        if draft.locationLabel.isEmpty {
            draft.locationLabel = "Current location"
        }
    }

    private func applySearchResult(_ result: LocationSearchResult) {
        draft.locationLabel = result.displayName
        draft.latitude = result.latitude
        draft.longitude = result.longitude
        draft.elevationFeet = result.elevationFeet
        locationResults = []
        locationQuery = result.displayName
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<UserLawnProfile, Value>) -> Binding<Value> {
        Binding {
            draft[keyPath: keyPath]
        } set: { newValue in
            draft[keyPath: keyPath] = newValue
        }
    }
}
