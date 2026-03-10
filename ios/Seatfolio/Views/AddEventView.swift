import SwiftUI

struct AddEventView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var eventName: String = ""
    @State private var venue: String = ""
    @State private var location: String = ""
    @State private var date: Date = Date()
    @State private var section: String = ""
    @State private var row: String = ""
    @State private var seats: String = ""
    @State private var seatCount: String = "1"
    @State private var pricePaid: String = ""
    @State private var priceSold: String = ""
    @State private var status: EventStatus = .pending
    @State private var notes: String = ""

    private let editingEvent: StandaloneEvent?

    init(editingEvent: StandaloneEvent? = nil) {
        self.editingEvent = editingEvent
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Event Name", text: $eventName)
                    TextField("Venue", text: $venue)
                    TextField("Location (City, State)", text: $location)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Seating") {
                    TextField("Section", text: $section)
                    TextField("Row", text: $row)
                    TextField("Seats (e.g. 1-2)", text: $seats)
                    HStack {
                        Text("Number of Tickets")
                        Spacer()
                        TextField("Count", text: $seatCount)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                Section("Pricing") {
                    HStack {
                        Text("Price Paid")
                        Spacer()
                        HStack(spacing: 2) {
                            Text("$")
                                .foregroundStyle(.secondary)
                            TextField("0.00", text: $pricePaid)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                    }
                    HStack {
                        Text("Price Sold")
                        Spacer()
                        HStack(spacing: 2) {
                            Text("$")
                                .foregroundStyle(.secondary)
                            TextField("0.00", text: $priceSold)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                    }
                    Picker("Status", selection: $status) {
                        ForEach(EventStatus.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(editingEvent == nil ? "Add Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEvent()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(eventName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let event = editingEvent {
                    eventName = event.eventName
                    venue = event.venue
                    location = event.location
                    date = event.date
                    section = event.section
                    row = event.row
                    seats = event.seats
                    seatCount = String(event.seatCount)
                    pricePaid = event.pricePaid > 0 ? String(format: "%.2f", event.pricePaid) : ""
                    priceSold = event.priceSold.map { String(format: "%.2f", $0) } ?? ""
                    status = event.status
                    notes = event.notes
                }
            }
        }
    }

    private func saveEvent() {
        let paid = Double(pricePaid) ?? 0
        let sold: Double? = priceSold.isEmpty ? nil : Double(priceSold)
        let count = max(1, Int(seatCount) ?? 1)
        let trimmedName = eventName.trimmingCharacters(in: .whitespaces)

        if let existing = editingEvent {
            var updated = existing
            updated.eventName = trimmedName
            updated.venue = venue
            updated.location = location
            updated.date = date
            updated.section = section
            updated.row = row
            updated.seats = seats
            updated.seatCount = count
            updated.pricePaid = paid
            updated.priceSold = sold
            updated.status = status
            updated.notes = notes
            store.updateEvent(updated)
        } else {
            let event = StandaloneEvent(
                eventName: trimmedName,
                venue: venue,
                location: location,
                date: date,
                section: section,
                row: row,
                seats: seats,
                seatCount: count,
                pricePaid: paid,
                priceSold: sold,
                status: status,
                notes: notes
            )
            store.addEvent(event)
        }
    }
}
