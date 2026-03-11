import Foundation

nonisolated struct TeamIDLogoMap {

    static func apiAbbr(for sportsDataTeamId: Int, leagueId: String) -> String? {
        switch leagueId {
        case "nhl": return nhlTeamIDs[sportsDataTeamId]
        case "nba": return nbaTeamIDs[sportsDataTeamId]
        case "nfl": return nflTeamIDs[sportsDataTeamId]
        case "mlb": return mlbTeamIDs[sportsDataTeamId]
        case "mls": return mlsTeamIDs[sportsDataTeamId]
        default: return nil
        }
    }

    static func logoURL(for sportsDataTeamId: Int, leagueId: String) -> String? {
        switch leagueId {
        case "nhl":
            guard let apiAbbr = nhlTeamIDs[sportsDataTeamId] else { return nil }
            return LeagueData.logoURLForAPIAbbr(apiAbbr, leagueId: "nhl")
        case "nba":
            guard let apiAbbr = nbaTeamIDs[sportsDataTeamId] else { return nil }
            return LeagueData.logoURLForAPIAbbr(apiAbbr, leagueId: "nba")
        case "nfl":
            guard let apiAbbr = nflTeamIDs[sportsDataTeamId] else { return nil }
            return LeagueData.logoURLForAPIAbbr(apiAbbr, leagueId: "nfl")
        case "mlb":
            guard let apiAbbr = mlbTeamIDs[sportsDataTeamId] else { return nil }
            return LeagueData.logoURLForAPIAbbr(apiAbbr, leagueId: "mlb")
        case "mls":
            guard let apiAbbr = mlsTeamIDs[sportsDataTeamId] else { return nil }
            return LeagueData.logoURLForAPIAbbr(apiAbbr, leagueId: "mls")
        default:
            return nil
        }
    }

    private static let nhlTeamIDs: [Int: String] = [
        1: "BOS",
        2: "BUF",
        3: "DET",
        4: "MON",
        5: "OTT",
        6: "TB",
        7: "TOR",
        8: "FLA",
        9: "CAR",
        10: "NJ",
        11: "NYI",
        12: "NYR",
        13: "PHI",
        14: "PIT",
        15: "WAS",
        16: "CBJ",
        17: "CHI",
        18: "DAL",
        19: "COL",
        20: "STL",
        21: "NAS",
        22: "WPG",
        23: "MIN",
        24: "CGY",
        25: "EDM",
        26: "LA",
        27: "SJ",
        28: "VAN",
        30: "ANA",
        35: "VEG",
        36: "SEA",
        41: "UTA",
    ]

    private static let nbaTeamIDs: [Int: String] = [
        1: "WAS",
        2: "CHA",
        3: "ATL",
        4: "MIA",
        5: "ORL",
        6: "NY",
        7: "PHI",
        8: "BKN",
        9: "BOS",
        10: "TOR",
        11: "CHI",
        12: "CLE",
        13: "IND",
        14: "DET",
        15: "MIL",
        16: "MIN",
        17: "UTA",
        18: "OKC",
        19: "POR",
        20: "DEN",
        21: "MEM",
        22: "HOU",
        23: "NO",
        24: "SA",
        25: "DAL",
        26: "GS",
        27: "LAL",
        28: "LAC",
        29: "PHO",
        30: "SAC",
    ]

    private static let nflTeamIDs: [Int: String] = [
        1: "ARI",
        2: "ATL",
        3: "BAL",
        4: "BUF",
        5: "CAR",
        6: "CHI",
        7: "CIN",
        8: "CLE",
        9: "DAL",
        10: "DEN",
        11: "DET",
        12: "GB",
        13: "HOU",
        14: "IND",
        15: "JAX",
        16: "KC",
        19: "MIA",
        20: "MIN",
        21: "NE",
        22: "NO",
        23: "NYG",
        24: "NYJ",
        25: "LV",
        26: "PHI",
        28: "PIT",
        29: "LAC",
        30: "SEA",
        31: "SF",
        32: "LAR",
        33: "TB",
        34: "TEN",
        35: "WAS",
    ]

    private static let mlbTeamIDs: [Int: String] = [
        1: "LAD",
        2: "CIN",
        3: "TOR",
        4: "PIT",
        5: "KC",
        9: "CHC",
        10: "CLE",
        11: "TB",
        12: "PHI",
        13: "SEA",
        14: "ARI",
        15: "SF",
        16: "CWS",
        17: "DET",
        18: "NYM",
        19: "BAL",
        20: "MIN",
        21: "LAA",
        22: "MIA",
        23: "COL",
        24: "OAK",
        25: "BOS",
        26: "ATL",
        28: "TEX",
        29: "NYY",
        30: "HOU",
        31: "STL",
        32: "MIL",
        33: "SD",
        35: "WSH",
    ]

    private static let mlsTeamIDs: [Int: String] = [
        :
    ]
}
