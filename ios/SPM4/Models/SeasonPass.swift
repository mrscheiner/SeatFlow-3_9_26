import Foundation

nonisolated struct SeatPair: Codable, Identifiable, Hashable, Sendable {
    let id: String
    var section: String
    var row: String
    var seats: String
    var cost: Double

    init(id: String = UUID().uuidString, section: String, row: String, seats: String, cost: Double) {
        self.id = id
        self.section = section
        self.row = row
        self.seats = seats
        self.cost = cost
    }
}

nonisolated struct SeasonPass: Codable, Identifiable, Hashable, Sendable {
    let id: String
    var leagueId: String
    var teamId: String
    var teamName: String
    var seasonLabel: String
    var seatPairs: [SeatPair]
    var sellAsPairsOnly: Bool
    var sales: [Sale]
    var games: [Game]
    var events: [StandaloneEvent]
    var backups: [Backup]
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        leagueId: String,
        teamId: String,
        teamName: String,
        seasonLabel: String,
        seatPairs: [SeatPair],
        sellAsPairsOnly: Bool = true,
        sales: [Sale] = [],
        games: [Game] = [],
        events: [StandaloneEvent] = [],
        backups: [Backup] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.leagueId = leagueId
        self.teamId = teamId
        self.teamName = teamName
        self.seasonLabel = seasonLabel
        self.seatPairs = seatPairs
        self.sellAsPairsOnly = sellAsPairsOnly
        self.sales = sales
        self.games = games
        self.events = events
        self.backups = backups
        self.createdAt = createdAt
    }

    var totalSeasonCost: Double {
        seatPairs.reduce(0) { $0 + $1.cost }
    }

    var totalRevenue: Double {
        sales.reduce(0) { $0 + $1.price }
    }

    var totalSeatsSold: Int {
        sales.count
    }

    var netProfitLoss: Double {
        totalRevenue - totalSeasonCost
    }
}
