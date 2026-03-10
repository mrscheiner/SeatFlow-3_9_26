import Foundation

nonisolated struct StandaloneEvent: Codable, Identifiable, Hashable, Sendable {
    let id: String
    var eventName: String
    var venue: String
    var location: String
    var date: Date
    var section: String
    var row: String
    var seats: String
    var seatCount: Int
    var pricePaid: Double
    var priceSold: Double?
    var status: EventStatus
    var notes: String

    init(
        id: String = UUID().uuidString,
        eventName: String,
        venue: String = "",
        location: String = "",
        date: Date = Date(),
        section: String = "",
        row: String = "",
        seats: String = "",
        seatCount: Int = 1,
        pricePaid: Double = 0,
        priceSold: Double? = nil,
        status: EventStatus = .pending,
        notes: String = ""
    ) {
        self.id = id
        self.eventName = eventName
        self.venue = venue
        self.location = location
        self.date = date
        self.section = section
        self.row = row
        self.seats = seats
        self.seatCount = seatCount
        self.pricePaid = pricePaid
        self.priceSold = priceSold
        self.status = status
        self.notes = notes
    }

    var profitLoss: Double? {
        guard let sold = priceSold else { return nil }
        return sold - pricePaid
    }
}

nonisolated enum EventStatus: String, Codable, CaseIterable, Sendable {
    case pending = "Pending"
    case sold = "Sold"
}
