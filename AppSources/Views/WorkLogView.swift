import SwiftUI

struct WorkLogView: View {
    @EnvironmentObject private var store: LawnStore
    @State private var showingAddSheet = false

    var sortedEntries: [WorkEntry] {
        store.workEntries.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Operating rule") {
                    Text("Until you buy a mower, trim lightly with the weed whacker and avoid scalping. During heat stress, leave the grass tall.")
                        .foregroundStyle(.secondary)
                }

                ForEach(sortedEntries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entry.type.rawValue)
                                .font(.headline)
                            Spacer()
                            Text(DateFormatter.lawnShort.string(from: entry.date))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(entry.area)
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
            .navigationTitle("Lawn Work")
            .toolbar {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddWorkEntryView()
            }
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        let idsToDelete = offsets.map { sortedEntries[$0].id }
        store.workEntries.removeAll { idsToDelete.contains($0.id) }
    }
}

struct AddWorkEntryView: View {
    @EnvironmentObject private var store: LawnStore
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var type: WorkType = .observation
    @State private var area = "Main slope"
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Picker("Type", selection: $type) {
                    ForEach(WorkType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                TextField("Area", text: $area)
                TextField("Notes", text: $notes, axis: .vertical)
            }
            .navigationTitle("Add Work")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        let entry = WorkEntry(date: date, type: type, area: area, notes: notes)
        store.workEntries.append(entry)
        dismiss()
    }
}
