import SwiftUI

nonisolated struct TeamThemeProvider {
    static func theme(for teamId: String) -> TeamTheme {
        guard let team = LeagueData.team(for: teamId) else { return .default }
        let primary = Color(hex: team.primaryColor)
        let secondary = Color(hex: team.secondaryColor)
        let accent = secondary
        return TeamTheme(
            primary: primary,
            secondary: secondary,
            accent: accent,
            gradient: [primary, primary.opacity(0.8), secondary.opacity(0.6)],
            textOnPrimary: .white
        )
    }
}
