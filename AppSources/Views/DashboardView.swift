import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: LawnStore

    var recommendation: LawnRecommendation {
        LawnAdvisor.recommendation(
            sevenDayRainfall: store.sevenDayRainfall,
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
                            title: "7-day rainfall",
                            value: store.sevenDayRainfall.inchesString,
                            subtitle: "Confirmed and estimated entries"
                        )
                        MetricCard(
                            title: "7-day watering",
                            value: store.sevenDayWaterEquivalent.inchesString,
                            subtitle: "Estimated irrigation equivalent"
                        )
                    }

                    SectionCard(title: "Property profile") {
                        LabeledContent("Location", value: store.profile.locationLabel)
                        LabeledContent("Elevation", value: "\(store.profile.elevationFeet) ft AMSL")
                        LabeledContent("Terrain", value: store.profile.terrain)
                        LabeledContent("Sun", value: store.profile.sunExposure)
                        LabeledContent("Equipment", value: store.profile.currentEquipment)
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
