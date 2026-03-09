import Foundation

nonisolated struct Game: Codable, Identifiable, Hashable, Sendable {
    let id: String
    var date: Date
    var opponent: String
    var opponentAbbr: String
    var venueName: String
    var time: String
    var gameNumber: Int
    var gameLabel: String
    var type: GameType
    var isHome: Bool

    init(
        id: String = UUID().uuidString,
        date: Date,
        opponent: String,
        opponentAbbr: String = "",
        venueName: String = "",
        time: String = "",
        gameNumber: Int = 0,
        gameLabel: String = "",
        type: GameType = .regular,
        isHome: Bool = true
    ) {
        self.id = id
        self.date = date
        self.opponent = opponent
        self.opponentAbbr = opponentAbbr
        self.venueName = venueName
        self.time = time
        self.gameNumber = gameNumber
        self.gameLabel = gameLabel
        self.type = type
        self.isHome = isHome
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        opponent = try container.decode(String.self, forKey: .opponent)
        opponentAbbr = try container.decodeIfPresent(String.self, forKey: .opponentAbbr) ?? ""
        venueName = try container.decodeIfPresent(String.self, forKey: .venueName) ?? ""
        time = try container.decodeIfPresent(String.self, forKey: .time) ?? ""
        gameNumber = try container.decodeIfPresent(Int.self, forKey: .gameNumber) ?? 0
        gameLabel = try container.decodeIfPresent(String.self, forKey: .gameLabel) ?? ""
        type = try container.decodeIfPresent(GameType.self, forKey: .type) ?? .regular
        isHome = try container.decodeIfPresent(Bool.self, forKey: .isHome) ?? true
    }

    var formattedDate: String {
        date.formatted(.dateTime.month(.abbreviated).day())
    }

    var formattedFullDate: String {
        date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    var monthYear: String {
        date.formatted(.dateTime.month(.wide).year())
    }

    var displayLabel: String {
        if !gameLabel.isEmpty { return gameLabel }
        if gameNumber > 0 { return "\(gameNumber)" }
        return ""
    }
}

nonisolated enum GameType: String, Codable, CaseIterable, Sendable {
    case preseason = "Preseason"
    case regular = "Regular"
    case playoff = "Playoff"
}
