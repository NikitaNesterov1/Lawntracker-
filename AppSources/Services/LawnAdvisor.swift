import Foundation

struct LawnRecommendation: Equatable {
    var title: String
    var detail: String
    var severity: RecommendationSeverity
}

enum RecommendationSeverity: String, Equatable {
    case good = "Good"
    case monitor = "Monitor"
    case action = "Action"
    case caution = "Caution"
}

struct LawnAdvisor {
    static func recommendation(sevenDayRainfall: Double, sevenDayWaterEquivalent: Double, lastWatering: WateringEntry?) -> LawnRecommendation {
        let totalMoisture = sevenDayRainfall + sevenDayWaterEquivalent
        let daysSinceWatering = lastWatering.map { Calendar.current.dateComponents([.day], from: $0.date, to: Date()).day ?? 99 } ?? 99

        if totalMoisture >= 1.0 {
            return LawnRecommendation(
                title: "Leave it alone",
                detail: "Moisture looks adequate for the last 7 days. Avoid extra watering unless new seed is actively drying out.",
                severity: .good
            )
        }

        if sevenDayRainfall < 0.5 && daysSinceWatering >= 5 {
            return LawnRecommendation(
                title: "Plan a deep watering",
                detail: "Rainfall is light and there has not been a recent deep watering. Water deeply, but avoid runoff on the slope.",
                severity: .action
            )
        }

        if totalMoisture < 0.75 {
            return LawnRecommendation(
                title: "Monitor closely",
                detail: "Moisture is borderline. Check the lawn during the afternoon for folding blades, gray-green color, or footprints that linger.",
                severity: .monitor
            )
        }

        return LawnRecommendation(
            title: "No major action",
            detail: "Conditions are acceptable. Keep the grass tall and avoid aggressive trimming during heat.",
            severity: .good
        )
    }

    static func currentPhase(for date: Date = Date()) -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        switch (month, day) {
        case (6, _), (7, _): return "Summer survival"
        case (8, 1...24): return "Pre-renovation prep"
        case (8, 25...31), (9, 1...10): return "Prime overseeding window"
        case (9, _), (10, _): return "Rooting and thickening"
        case (11, _): return "Winterizer window"
        default: return "Dormant or maintenance period"
        }
    }
}
