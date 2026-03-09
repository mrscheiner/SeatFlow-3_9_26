import Foundation
import SwiftUI

nonisolated struct League: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let shortName: String
    let logoURL: String
    let teams: [Team]
}

nonisolated struct Team: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let city: String
    let abbreviation: String
    let logoURL: String
    let primaryColor: String
    let secondaryColor: String
    let apiAbbr: String
}

struct TeamTheme: Sendable {
    let primary: Color
    let secondary: Color
    let accent: Color
    let gradient: [Color]
    let textOnPrimary: Color

    static let `default` = TeamTheme(
        primary: Color(hex: "002B5C"),
        secondary: Color(hex: "B9975B"),
        accent: Color(hex: "C8102E"),
        gradient: [Color(hex: "002B5C"), Color(hex: "001F45"), Color(hex: "B9975B")],
        textOnPrimary: .white
    )
}

extension Color {
    nonisolated init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
