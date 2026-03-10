import Foundation

nonisolated struct Sale: Codable, Identifiable, Hashable, Sendable {
    let id: String
    var gameId: String
    var opponent: String
    var opponentAbbr: String
    var leagueId: String
    var gameDate: Date
    var section: String
    var row: String
    var seats: String
    var price: Double
    var soldDate: Date
    var status: SaleStatus

    init(
        id: String = UUID().uuidString,
        gameId: String,
        opponent: String,
        opponentAbbr: String = "",
        leagueId: String = "",
        gameDate: Date,
        section: String,
        row: String,
        seats: String,
        price: Double,
        soldDate: Date = Date(),
        status: SaleStatus = .pending
    ) {
        self.id = id
        self.gameId = gameId
        self.opponent = opponent
        self.opponentAbbr = opponentAbbr
        self.leagueId = leagueId
        self.gameDate = gameDate
        self.section = section
        self.row = row
        self.seats = seats
        self.price = price
        self.soldDate = soldDate
        self.status = status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        gameId = try container.decode(String.self, forKey: .gameId)
        opponent = try container.decode(String.self, forKey: .opponent)
        opponentAbbr = try container.decodeIfPresent(String.self, forKey: .opponentAbbr) ?? ""
        leagueId = try container.decodeIfPresent(String.self, forKey: .leagueId) ?? ""
        gameDate = try container.decode(Date.self, forKey: .gameDate)
        section = try container.decode(String.self, forKey: .section)
        row = try container.decode(String.self, forKey: .row)
        seats = try container.decode(String.self, forKey: .seats)
        price = try container.decode(Double.self, forKey: .price)
        soldDate = try container.decode(Date.self, forKey: .soldDate)
        status = try container.decode(SaleStatus.self, forKey: .status)
    }
}

nonisolated enum SaleStatus: String, Codable, CaseIterable, Sendable {
    case pending = "Pending"
    case paid = "Paid"
    case perSeat = "Per Seat"
}
