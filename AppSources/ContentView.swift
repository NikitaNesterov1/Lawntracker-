import Foundation
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: LawnStore
    @State private var selectedTab = AppTab.previewDefault
    @State private var showingOnboarding = false

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
        .onAppear {
            if !store.userProfile.isOnboardingComplete && !AppTab.previewSkipsOnboarding {
                showingOnboarding = true
            }
        }
        .sheet(isPresented: $showingOnboarding) {
            LawnOnboardingView()
                .interactiveDismissDisabled(!store.userProfile.isOnboardingComplete && !AppTab.previewSkipsOnboarding)
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

    static var previewSkipsOnboarding: Bool {
        ProcessInfo.processInfo.environment["PREVIEW_SKIP_ONBOARDING"] == "1"
    }
}
