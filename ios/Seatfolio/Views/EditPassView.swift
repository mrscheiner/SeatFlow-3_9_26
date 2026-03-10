import SwiftUI

struct EditPassView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var seasonLabel = ""
    @State private var seatPairs: [SeatPair] = []
    @State private var newSection = ""
    @State private var newRow = ""
    @State private var newSeats = ""
    @State private var newCost = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Season Label") {
                    TextField("Season Label", text: $seasonLabel)
                }

                Section("Seat Pairs") {
                    ForEach(seatPairs) { pair in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sec \(pair.section), Row \(pair.row)")
                                    .font(.body.weight(.medium))
                                Text("Seats: \(pair.seats)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(pair.cost, format: .currency(code: "USD"))
                                .font(.subheadline.weight(.medium))
                        }
                    }
                    .onDelete { offsets in
                        seatPairs.remove(atOffsets: offsets)
                    }
                }

                Section("Add Seat Pair") {
                    HStack(spacing: 10) {
                        TextField("Section", text: $newSection)
                        TextField("Row", text: $newRow)
                    }
                    HStack(spacing: 10) {
                        TextField("Seats", text: $newSeats)
                        TextField("Cost ($)", text: $newCost)
                            .keyboardType(.decimalPad)
                    }
                    Button {
                        addSeatPair()
                    } label: {
                        Label("Add Seat Pair", systemImage: "plus.circle.fill")
                    }
                    .disabled(newSection.isEmpty || newRow.isEmpty || newSeats.isEmpty || newCost.isEmpty)
                }
            }
            .navigationTitle("Edit Pass")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let pass = store.activePass {
                    seasonLabel = pass.seasonLabel
                    seatPairs = pass.seatPairs
                }
            }
        }
    }

    private func addSeatPair() {
        guard let cost = Double(newCost) else { return }
        let pair = SeatPair(section: newSection, row: newRow, seats: newSeats, cost: cost)
        seatPairs.append(pair)
        newSection = ""
        newRow = ""
        newSeats = ""
        newCost = ""
    }

    private func saveChanges() {
        guard var pass = store.activePass else { return }
        pass.seasonLabel = seasonLabel
        pass.seatPairs = seatPairs
        store.updatePass(pass)
    }
}
