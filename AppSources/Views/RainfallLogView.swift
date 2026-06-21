import SwiftUI

struct RainfallLogView: View {
    @EnvironmentObject private var store: LawnStore
    @State private var showingAddSheet = false

    var sortedEntries: [RainfallEntry] {
        store.rainfallEntries.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Totals") {
                    LabeledContent("Logged rain, last 7 days", value: store.sevenDayRainfall.inchesString)
                    LabeledContent("Logged rain, this week", value: store.currentWeekRainfall.inchesString)
                    if let estimate = store.rainfallSummary.weatherEstimatedPreviousSevenDays {
                        LabeledContent("Weather estimate, previous 7 days", value: estimate.inchesString)
                    }
                    if let prediction = store.rainfallSummary.predictedNextFourteenDays {
                        LabeledContent("Forecast, next 14 days", value: prediction.inchesString)
                    }
                    if let secondWeek = store.rainfallSummary.predictedSecondWeekRainfall {
                        LabeledContent("Forecast, days 8-14", value: secondWeek.inchesString)
                    }
                }

                ForEach(sortedEntries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(DateFormatter.lawnShort.string(from: entry.date))
                                .font(.headline)
                            Spacer()
                            Text(entry.amountInches.inchesString)
                                .font(.headline)
                        }
                        Text(entry.source.rawValue)
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
            .navigationTitle("Rainfall")
            .toolbar {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddRainfallEntryView()
            }
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        let idsToDelete = offsets.map { sortedEntries[$0].id }
        store.rainfallEntries.removeAll { idsToDelete.contains($0.id) }
    }
}

struct AddRainfallEntryView: View {
    @EnvironmentObject private var store: LawnStore
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var amount = "0.25"
    @State private var source: RainfallSource = .rainGauge
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Amount in inches", text: $amount)
                    .keyboardType(.decimalPad)
                Picker("Source", selection: $source) {
                    ForEach(RainfallSource.allCases) { source in
                        Text(source.rawValue).tag(source)
                    }
                }
                TextField("Notes", text: $notes, axis: .vertical)
            }
            .navigationTitle("Add Rainfall")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(Double(amount) == nil)
                }
            }
        }
    }

    private func save() {
        let entry = RainfallEntry(
            date: date,
            amountInches: Double(amount) ?? 0,
            source: source,
            notes: notes
        )
        store.rainfallEntries.append(entry)
        dismiss()
    }
}
