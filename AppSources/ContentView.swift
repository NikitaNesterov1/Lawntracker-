import Foundation
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = AppTab.previewDefault

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "leaf") }
                .tag(AppTab.dashboard)

            LawnIntelligenceView()
                .tabItem { Label("Info", systemImage: "location.magnifyingglass") }
                .tag(AppTab.info)

            RainfallLogView()
                .tabItem { Label("Rain", systemImage: "cloud.rain") }
                .tag(AppTab.rain)

            WateringLogView()
                .tabItem { Label("Water", systemImage: "drop") }
                .tag(AppTab.water)

            WorkLogView()
                .tabItem { Label("Work", systemImage: "wrench.and.screwdriver") }
                .tag(AppTab.work)

            SeasonalPlanView()
                .tabItem { Label("Plan", systemImage: "calendar") }
                .tag(AppTab.plan)

            PlantInventoryView()
                .tabItem { Label("Plants", systemImage: "tree") }
                .tag(AppTab.plants)
        }
    }
}

private enum AppTab: String, Hashable {
    case dashboard
    case info
    case rain
    case water
    case work
    case plan
    case plants

    static var previewDefault: AppTab {
        let requestedTab = ProcessInfo.processInfo.environment["PREVIEW_TAB"] ?? ""
        return AppTab(rawValue: requestedTab) ?? .dashboard
    }
}
