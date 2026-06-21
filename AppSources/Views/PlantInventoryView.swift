import SwiftUI

struct PlantInventoryView: View {
    @EnvironmentObject private var store: LawnStore
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.plants) { plant in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(plant.name)
                                .font(.headline)
                            Spacer()
                            Text(plant.status.rawValue)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        Text(plant.location)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if !plant.notes.isEmpty {
                            Text(plant.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    store.plants.remove(atOffsets: offsets)
                }
            }
            .navigationTitle("Plants")
            .toolbar {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddPlantView()
            }
        }
    }
}

struct AddPlantView: View {
    @EnvironmentObject private var store: LawnStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var location = ""
    @State private var status: PlantStatus = .monitoring
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Plant name", text: $name)
                TextField("Location", text: $location)
                Picker("Status", selection: $status) {
                    ForEach(PlantStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                TextField("Notes", text: $notes, axis: .vertical)
            }
            .navigationTitle("Add Plant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        let plant = PlantItem(name: name, location: location, plantedDate: nil, status: status, notes: notes)
        store.plants.append(plant)
        dismiss()
    }
}
