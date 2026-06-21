import SwiftUI

@main
struct BushkillLawnTrackerApp: App {
    @StateObject private var store = LawnStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
