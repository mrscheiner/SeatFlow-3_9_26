// TeamLogoAudit.swift
// Utility to print which team logos are cached and which are missing

import Foundation

class TeamLogoAudit {
    static func audit(teamNames: [String]) {
        let scraper = TeamLogoScraper.shared
        var have: [String] = []
        var missing: [String] = []
        for name in teamNames {
            if scraper.isLogoCached(for: name) {
                have.append(name)
            } else {
                missing.append(name)
            }
        }
        print("\nTeam Logo Audit\n==============\n")
        print("Logos Present (")
        print(have.count, "):")
        for name in have.sorted() { print("  ✓", name) }
        print("\nLogos Missing (")
        print(missing.count, "):")
        for name in missing.sorted() { print("  ✗", name) }
        print("")
    }
}
