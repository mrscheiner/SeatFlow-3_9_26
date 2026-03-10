import Foundation

nonisolated struct Backup: Codable, Identifiable, Hashable, Sendable {
    let id: String
    var label: String
    var timestamp: Date
    var salesCount: Int
    var eventsCount: Int
    var salesData: [Sale]
    var eventsData: [StandaloneEvent]
    var gamesData: [Game]

    init(
        id: String = UUID().uuidString,
        label: String,
        timestamp: Date = Date(),
        salesCount: Int,
        eventsCount: Int,
        salesData: [Sale],
        eventsData: [StandaloneEvent],
        gamesData: [Game]
    ) {
        self.id = id
        self.label = label
        self.timestamp = timestamp
        self.salesCount = salesCount
        self.eventsCount = eventsCount
        self.salesData = salesData
        self.eventsData = eventsData
        self.gamesData = gamesData
    }
}
