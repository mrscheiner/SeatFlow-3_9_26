// TeamLogos.swift
// Centralized team logo resolver for Seatfolio

import Foundation

struct TeamLogos {
    // Maps full team name to local asset name
    // This dictionary is auto-generated from LeagueData.swift for consistency
    static let logos: [String: String] = {
        var dict = [String: String]()
        let leaguePrefixes = [
            "nhl": "nhl_",
            "nba": "nba_",
            "nfl": "nfl_",
            "mlb": "mlb_",
            "mls": "mls_"
        ]
        for league in LeagueData.allLeagues {
            let prefix = leaguePrefixes[league.id] ?? ""
            for team in league.teams {
                let fullName = "\(team.city) \(team.name)"
                let assetName = "\(prefix)\(team.name.replacingOccurrences(of: " ", with: "").lowercased())"
                dict[fullName] = assetName
                // Also allow just team name as a key for fallback
                dict[team.name] = assetName
            }
        }
        // Special cases for known alternate names
        dict["Inter Miami CF"] = "mls_inter_miami"
        return dict
    }()

    /// Returns the asset name for a given team name, or a fallback if not found or missing
    static func logo(for teamName: String) -> String {
        // Try direct match first
        if let asset = logos[teamName] {
            return asset
        }
        let lowered = teamName.lowercased()
        // Try to match by city and mascot for all teams
        for (name, asset) in logos {
            let n = name.lowercased()
            if lowered == n || lowered.contains(n) || n.contains(lowered) {
                return asset
            }
        }
        // Fallbacks for Miami and other generic cases
        if lowered.contains("miami") {
            return "generic_miami"
        }
        return "generic_team"
    }
}
