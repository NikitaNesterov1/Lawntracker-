import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: LawnStore

    var recommendation: LawnRecommendation {
        let summary = store.rainfallSummary
        LawnAdvisor.recommendation(
            sevenDayRainfall: summary.bestObservedRainfall,
            sevenDayWaterEquivalent: store.sevenDayWaterEquivalent,
            lastWatering: store.lastWatering
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionCard(title: "Lawn status") {
                        Text(recommendation.title)
                            .font(.title2.bold())
                        Text(recommendation.detail)
                            .foregroundStyle(.secondary)
                        Text("Phase: \(LawnAdvisor.currentPhase())")
                            .font(.subheadline.weight(.semibold))
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricCard(
                            title: "Logged rain",
                            value: store.sevenDayRainfall.inchesString,
                            subtitle: "Last 7 calendar days"
                        )
                        MetricCard(
                            title: "7-day watering",
                            value: store.sevenDayWaterEquivalent.inchesString,
                            subtitle: "Estimated irrigation equivalent"
                        )
                        MetricCard(
                            title: "Rain forecast",
                            value: store.rainfallSummary.predictedNextSevenDays?.inchesString ?? "--",
                            subtitle: "Today + next 6 days"
                        )
                        MetricCard(
                            title: "Observed water",
                            value: store.rainfallSummary.observedWaterTotal.inchesString,
                            subtitle: store.rainfallSummary.observedSourceLabel
                        )
                    }

                    SectionCard(title: "Property profile") {
                        LabeledContent("Location", value: store.userProfile.locationLabel)
                        if let elevationFeet = store.userProfile.elevationFeet {
                            LabeledContent("Elevation", value: "\(elevationFeet) ft AMSL")
                        }
                        LabeledContent("Goal", value: store.userProfile.lawnGoal.rawValue)
                        LabeledContent("Grass", value: store.userProfile.grassType.rawValue)
                        LabeledContent("Sun", value: store.userProfile.sunExposure.rawValue)
                        LabeledContent("Watering", value: store.userProfile.irrigationMethod.rawValue)
                    }

                    SectionCard(title: "Current doctrine") {
                        Text(store.profile.currentDoctrine)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Lawn HQ")
        }
    }
}
