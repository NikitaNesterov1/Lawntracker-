import Foundation

enum SampleData {
    static let calendar = Calendar.current

    static var rainfallEntries: [RainfallEntry] {
        [
            RainfallEntry(date: daysAgo(3), amountInches: 0.20, source: .weatherEstimate, notes: "Sample estimated shower"),
            RainfallEntry(date: daysAgo(8), amountInches: 0.35, source: .weatherEstimate, notes: "Sample older rainfall")
        ]
    }

    static var wateringEntries: [WateringEntry] {
        [
            WateringEntry(date: daysAgo(4), durationMinutes: 45, zone: "Main slope", estimatedInches: 0.50, notes: "Sample deep watering")
        ]
    }

    static var workEntries: [WorkEntry] {
        [
            WorkEntry(date: daysAgo(6), type: .seeding, area: "Thin/bare patch", notes: "Recent overseeding; keep traffic low"),
            WorkEntry(date: daysAgo(2), type: .observation, area: "Whole lawn", notes: "Watch for heat stress and dry edges")
        ]
    }

    static var plants: [PlantItem] {
        [
            PlantItem(name: "White rhododendron", location: "Privacy screen area", plantedDate: nil, status: .monitoring, notes: "Watch deer pressure and watering"),
            PlantItem(name: "Hybrid American chestnut", location: "Yard", plantedDate: nil, status: .stressed, notes: "One tree partially alive; monitor trunk growth"),
            PlantItem(name: "Yellow groove bamboo", location: "Privacy planting", plantedDate: nil, status: .monitoring, notes: "Track spread and containment"),
            PlantItem(name: "Phenomenal lavender", location: "Stone wall / garden edge", plantedDate: nil, status: .monitoring, notes: "Needs drainage and sun")
        ]
    }

    static var seasonalTasks: [SeasonalTask] {
        [
            SeasonalTask(season: "Summer 2026", window: "June 21 - July 15", title: "Survival mode", details: "Do not scalp. Avoid herbicides on recently seeded areas. Water deeply only when needed.", priority: .critical),
            SeasonalTask(season: "Summer 2026", window: "July 15 - August 20", title: "Maintain and prepare", details: "Keep grass tall, prevent drought stress, and avoid major disturbance.", priority: .high),
            SeasonalTask(season: "Fall 2026", window: "August 25 - September 10", title: "Prime overseeding window", details: "Mow lower than normal, rake thin areas, overseed, starter fertilizer, keep seedbed moist.", priority: .critical),
            SeasonalTask(season: "Fall 2026", window: "October", title: "Rooting and thickening", details: "Support Kentucky bluegrass establishment and overall density.", priority: .high),
            SeasonalTask(season: "Late Fall 2026", window: "November", title: "Winterizer", details: "Apply winterizer fertilizer when growth slows but grass is still active.", priority: .medium)
        ]
    }

    static func daysAgo(_ days: Int) -> Date {
        calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
}
