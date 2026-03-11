// TeamLogoAudit.swift
// Swift script to find all missing team logo mappings in all leagues
// Usage: swift TeamLogoAudit.swift <path_to_backup.json>

import Foundation

struct Sale: Codable {
    var opponentAbbr: String?
    var leagueId: String?
}

struct Game: Codable {
    var opponentAbbr: String?
    var homeAbbr: String?
    var leagueId: String?
}

// Load LeagueData.swift as a static dictionary (manually maintained)
// For this script, we will hardcode the league/team mapping from LeagueData.swift
// (In production, you would parse LeagueData.swift or expose it as JSON)

// Example: Replace with your actual league/team mapping
let leagueTeams: [String: Set<String>] = [
    "nhl": [
        "ANA", "BOS", "BUF", "CGY", "CAR", "CHI", "COL", "CBJ", "DAL", "DET", "EDM", "FLA", "LAK", "MIN", "MTL", "NSH", "NJD", "NYI", "NYR", "OTT", "PHI", "PIT", "SJS", "SEA", "STL", "TBL", "TOR", "VAN", "VGK", "WSH", "WPG"
    ],
    "nba": [
        "ATL", "BKN", "BOS", "CHA", "CHI", "CLE", "DAL", "DEN", "DET", "GSW", "HOU", "IND", "LAC", "LAL", "MEM", "MIA", "MIL", "MIN", "NOP", "NYK", "OKC", "ORL", "PHI", "PHX", "POR", "SAC", "SAS", "TOR", "UTA", "WAS"
    ],
    "nfl": [
        "ARI", "ATL", "BAL", "BUF", "CAR", "CHI", "CIN", "CLE", "DAL", "DEN", "DET", "GB", "HOU", "IND", "JAX", "KC", "LV", "LAC", "LAR", "MIA", "MIN", "NE", "NO", "NYG", "NYJ", "PHI", "PIT", "SF", "SEA", "TB", "TEN", "WAS"
    ],
    "mlb": [
        "ARI", "ATL", "BAL", "BOS", "CHC", "CWS", "CIN", "CLE", "COL", "DET", "HOU", "KC", "LAA", "LAD", "MIA", "MIL", "MIN", "NYM", "NYY", "OAK", "PHI", "PIT", "SD", "SF", "SEA", "STL", "TB", "TEX", "TOR", "WAS"
    ],
    "mls": [
        "ATL", "AUS", "CLB", "CIN", "COL", "HOU", "MIA", "LAFC", "LAG", "MIN", "MTL", "NSH", "NE", "NYC", "NYRB", "ORL", "PHI", "POR", "RSL", "SEA", "SKC", "SJ", "STL", "TOR", "VAN", "DC", "CLT"
    ]
]

func loadBackup(path: String) -> [String: Set<String>] {
    guard let data = FileManager.default.contents(atPath: path) else {
        print("Could not read file at \(path)")
        exit(1)
    }
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        print("Could not parse JSON")
        exit(1)
    }
    var found: [String: Set<String>] = [:]
    // 1. salesData: opponentAbbr
    if let salesData = json["salesData"] as? [String: [String: [String: Any]]] {
        for (leagueId, games) in salesData {
            for (_, saleDict) in games {
                if let abbr = saleDict["opponentAbbr"] as? String, !abbr.isEmpty {
                    found[leagueId, default: []].insert(abbr.uppercased())
                }
            }
        }
    }
    // 2. seasonPasses: teamAbbreviation
    if let seasonPasses = json["seasonPasses"] as? [[String: Any]] {
        for pass in seasonPasses {
            if let leagueId = pass["leagueId"] as? String {
                if let abbr = pass["teamAbbreviation"] as? String, !abbr.isEmpty {
                    found[leagueId, default: []].insert(abbr.uppercased())
                }
            }
        }
    }
    // 3. teams: teamAbbreviation and teamId
    if let teams = json["teams"] as? [[String: Any]] {
        for team in teams {
            if let leagueId = team["leagueId"] as? String {
                if let abbr = team["teamAbbreviation"] as? String, !abbr.isEmpty {
                    found[leagueId, default: []].insert(abbr.uppercased())
                }
                // Optionally, also check teamId for dashes/underscores
                if let teamId = team["teamId"] as? String, !teamId.isEmpty {
                    // Try to extract abbreviation from teamId if possible (e.g., mia-nfl or mia_nfl)
                    let idParts = teamId.components(separatedBy: CharacterSet(charactersIn: "-_"))
                    if idParts.count > 1, let abbr = idParts.first, abbr.count == 3 {
                        found[leagueId, default: []].insert(abbr.uppercased())
                    }
                }
            }
        }
    }
    return found
}

func auditMissingLogos(backupPath: String) {
    let found = loadBackup(path: backupPath)
    for (league, abbrs) in found {
        let known = leagueTeams[league] ?? []
        let missing = abbrs.subtracting(known)
        if !missing.isEmpty {
            print("\nMissing in \(league.uppercased()):")
            for abbr in missing.sorted() {
                print("  - \(abbr)")
            }
        }
    }
}

if CommandLine.arguments.count < 2 {
    print("Usage: swift TeamLogoAudit.swift <path_to_backup.json>")
    exit(1)
}

auditMissingLogos(backupPath: CommandLine.arguments[1])
