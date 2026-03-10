import Foundation

nonisolated struct TimezoneHelper {
    static let est = TimeZone(identifier: "America/New_York")!

    private static let cityTimezones: [String: String] = [
        "Anaheim": "America/Los_Angeles",
        "Arizona": "America/Phoenix",
        "Atlanta": "America/New_York",
        "Austin": "America/Chicago",
        "Baltimore": "America/New_York",
        "Boston": "America/New_York",
        "Brooklyn": "America/New_York",
        "Buffalo": "America/New_York",
        "Calgary": "America/Edmonton",
        "Carolina": "America/New_York",
        "Charlotte": "America/New_York",
        "Chicago": "America/Chicago",
        "Cincinnati": "America/New_York",
        "Cleveland": "America/New_York",
        "Colorado": "America/Denver",
        "Columbus": "America/New_York",
        "Dallas": "America/Chicago",
        "Denver": "America/Denver",
        "Detroit": "America/Detroit",
        "Edmonton": "America/Edmonton",
        "Florida": "America/New_York",
        "Golden State": "America/Los_Angeles",
        "Green Bay": "America/Chicago",
        "Houston": "America/Chicago",
        "Indiana": "America/Indiana/Indianapolis",
        "Indianapolis": "America/Indiana/Indianapolis",
        "Jacksonville": "America/New_York",
        "Kansas City": "America/Chicago",
        "LA": "America/Los_Angeles",
        "Las Vegas": "America/Los_Angeles",
        "Los Angeles": "America/Los_Angeles",
        "Memphis": "America/Chicago",
        "Miami": "America/New_York",
        "Milwaukee": "America/Chicago",
        "Minnesota": "America/Chicago",
        "Montreal": "America/Toronto",
        "Nashville": "America/Chicago",
        "New England": "America/New_York",
        "New Jersey": "America/New_York",
        "New Orleans": "America/Chicago",
        "New York": "America/New_York",
        "Oakland": "America/Los_Angeles",
        "Oklahoma City": "America/Chicago",
        "Orlando": "America/New_York",
        "Ottawa": "America/Toronto",
        "Philadelphia": "America/New_York",
        "Phoenix": "America/Phoenix",
        "Pittsburgh": "America/New_York",
        "Portland": "America/Los_Angeles",
        "Sacramento": "America/Los_Angeles",
        "Salt Lake": "America/Denver",
        "San Antonio": "America/Chicago",
        "San Diego": "America/Los_Angeles",
        "San Francisco": "America/Los_Angeles",
        "San Jose": "America/Los_Angeles",
        "Seattle": "America/Los_Angeles",
        "St. Louis": "America/Chicago",
        "Tampa Bay": "America/New_York",
        "Tennessee": "America/Chicago",
        "Texas": "America/Chicago",
        "Toronto": "America/Toronto",
        "Utah": "America/Denver",
        "Vancouver": "America/Vancouver",
        "Vegas": "America/Los_Angeles",
        "Washington": "America/New_York",
        "Winnipeg": "America/Winnipeg"
    ]

    static func timezone(for teamId: String) -> TimeZone {
        guard let team = LeagueData.team(for: teamId) else { return est }
        return cityTimezones[team.city].flatMap { TimeZone(identifier: $0) } ?? est
    }

    static func formatGameTime(_ date: Date, teamId: String) -> String {
        let tz = timezone(for: teamId)
        let df = DateFormatter()
        df.dateFormat = "h:mm a zzz"
        df.timeZone = tz
        return df.string(from: date)
    }

    static func formatEST(_ date: Date, style: ESTStyle = .dateTime) -> String {
        let df = DateFormatter()
        df.timeZone = est
        switch style {
        case .dateTime:
            df.dateFormat = "MMM d, h:mm a 'EST'"
        case .timeOnly:
            df.dateFormat = "h:mm a 'EST'"
        case .full:
            df.dateFormat = "EEEE, MMM d 'at' h:mm a 'EST'"
        }
        return df.string(from: date)
    }

    nonisolated enum ESTStyle: Sendable {
        case dateTime
        case timeOnly
        case full
    }
}
