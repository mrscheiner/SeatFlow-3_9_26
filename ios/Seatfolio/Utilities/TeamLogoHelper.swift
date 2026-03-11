import Foundation

nonisolated struct TeamLogoHelper {
    static func assetName(league: String, teamID: String) -> String {
        "logos/\(league.lowercased())/\(teamID.lowercased())"
    }

    static func assetNameForTeam(_ teamId: String) -> String? {
        guard let league = LeagueData.allLeagues.first(where: { $0.teams.contains(where: { $0.id == teamId }) }) else { return nil }
        return assetName(league: league.id, teamID: teamId)
    }

    static func assetNameForLeague(_ leagueId: String) -> String {
        "logos/\(leagueId.lowercased())/\(leagueId.lowercased())"
    }

    static func assetNameForOpponent(
        opponentAbbr: String,
        leagueId: String,
        opponentTeamId: Int? = nil
    ) -> String? {
        if let sportsDataId = opponentTeamId,
           let apiAbbr = TeamIDLogoMap.apiAbbr(for: sportsDataId, leagueId: leagueId),
           let team = LeagueData.teamByAPIAbbr(apiAbbr, leagueId: leagueId) {
            return assetName(league: leagueId, teamID: team.id)
        }

        if !opponentAbbr.isEmpty {
            if let team = LeagueData.teamByAPIAbbr(opponentAbbr, leagueId: leagueId) {
                return assetName(league: leagueId, teamID: team.id)
            }
            for league in LeagueData.allLeagues {
                if let team = league.teams.first(where: { $0.apiAbbr == opponentAbbr }) {
                    return assetName(league: league.id, teamID: team.id)
                }
            }
        }

        return nil
    }

    static func assetNameByTeamName(_ name: String) -> String? {
        guard !name.isEmpty else { return nil }
        let lowered = name.lowercased()
        for league in LeagueData.allLeagues {
            if let team = league.teams.first(where: {
                lowered.contains($0.name.lowercased()) ||
                lowered.contains($0.city.lowercased()) ||
                $0.name.lowercased().contains(lowered) ||
                "\($0.city) \($0.name)".lowercased().contains(lowered)
            }) {
                return assetName(league: league.id, teamID: team.id)
            }
        }
        return nil
    }
}
