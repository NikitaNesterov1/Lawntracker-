import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "leaf") }

            LawnIntelligenceView()
                .tabItem { Label("Info", systemImage: "location.magnifyingglass") }

            RainfallLogView()
                .tabItem { Label("Rain", systemImage: "cloud.rain") }

            WateringLogView()
                .tabItem { Label("Water", systemImage: "drop") }

            WorkLogView()
                .tabItem { Label("Work", systemImage: "wrench.and.screwdriver") }

            SeasonalPlanView()
                .tabItem { Label("Plan", systemImage: "calendar") }

            PlantInventoryView()
                .tabItem { Label("Plants", systemImage: "tree") }
        }
    }
}
