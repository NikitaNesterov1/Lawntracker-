import SwiftUI

struct SeasonalPlanView: View {
    @EnvironmentObject private var store: LawnStore

    var body: some View {
        NavigationStack {
            List {
                Section("Current phase") {
                    Text(LawnAdvisor.currentPhase())
                        .font(.headline)
                    Text("This app is built around summer survival first, then a major late-August to early-September renovation push.")
                        .foregroundStyle(.secondary)
                }

                ForEach(store.seasonalTasks) { task in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(task.title)
                                .font(.headline)
                            Spacer()
                            Text(task.priority.rawValue)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        Text("\(task.season) - \(task.window)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(task.details)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Seasonal Plan")
        }
    }
}
