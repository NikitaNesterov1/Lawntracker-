import SwiftUI

struct WateringLogView: View {
    @EnvironmentObject private var store: LawnStore
    @State private var showingAddSheet = false

    var sortedEntries: [WateringEntry] {
        store.wateringEntries.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("7-day water equivalent")
                        Spacer()
                        Text(store.sevenDayWaterEquivalent.inchesString)
                            .font(.headline)
                    }
                }

                ForEach(sortedEntries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(DateFormatter.lawnShort.string(from: entry.date))
                                .font(.headline)
                            Spacer()
                            Text(entry.estimatedInches.inchesString)
                                .font(.headline)
                        }
                        Text("\(entry.zone) - \(entry.durationMinutes) min")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if !entry.notes.isEmpty {
                            Text(entry.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    deleteEntries(at: indexSet)
                }
            }
            .navigationTitle("Watering")
            .toolbar {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddWateringEntryView()
            }
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        let idsToDelete = offsets.map { sortedEntries[$0].id }
        store.wateringEntries.removeAll { idsToDelete.contains($0.id) }
    }
}

struct AddWateringEntryView: View {
    @EnvironmentObject private var store: LawnStore
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var duration = "45"
    @State private var zone = "Main slope"
    @State private var estimatedInches = "0.50"
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Duration minutes", text: $duration)
                    .keyboardType(.numberPad)
                TextField("Zone", text: $zone)
                TextField("Estimated inches", text: $estimatedInches)
                    .keyboardType(.decimalPad)
                TextField("Notes", text: $notes, axis: .vertical)
            }
            .navigationTitle("Add Watering")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(Int(duration) == nil || Double(estimatedInches) == nil)
                }
            }
        }
    }

    private func save() {
        let entry = WateringEntry(
            date: date,
            durationMinutes: Int(duration) ?? 0,
            zone: zone,
            estimatedInches: Double(estimatedInches) ?? 0,
            notes: notes
        )
        store.wateringEntries.append(entry)
        dismiss()
    }
}
