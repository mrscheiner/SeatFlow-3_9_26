// TeamLogoDownloader.swift
// Swift script to fetch and save all team logos for NFL, NBA, NHL, MLB, MLS from SportsDataIO
// Usage: Run as a macOS command-line tool or integrate into your app for one-time logo download

import Foundation
#if canImport(AppKit)
import AppKit
#endif

struct League {
    let name: String
    let endpoint: String
    let folder: String
}

let leagues: [League] = [
    League(name: "NFL", endpoint: "https://api.sportsdata.io/v3/nfl/scores/json/AllTeams?key=9b42211a91c1440795cd6217baa9e334", folder: "team_logos/NFL"),
    League(name: "NBA", endpoint: "https://api.sportsdata.io/v3/nba/scores/json/Teams?key=9b42211a91c1440795cd6217baa9e334", folder: "team_logos/NBA"),
    League(name: "NHL", endpoint: "https://api.sportsdata.io/v3/nhl/scores/json/Teams?key=9b42211a91c1440795cd6217baa9e334", folder: "team_logos/NHL"),
    League(name: "MLB", endpoint: "https://api.sportsdata.io/v3/mlb/scores/json/Teams?key=9b42211a91c1440795cd6217baa9e334", folder: "team_logos/MLB"),
    League(name: "MLS", endpoint: "https://api.sportsdata.io/v3/soccer/scores/json/Teams?key=9b42211a91c1440795cd6217baa9e334", folder: "team_logos/MLS")
]

func safeFileName(_ name: String) -> String {
    return name.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "/", with: "_")
}

func fetchAndSaveLogos() {
    let fileManager = FileManager.default
    for league in leagues {
        print("\nFetching logos for \(league.name)...")
        let folderURL = URL(fileURLWithPath: fileManager.currentDirectoryPath).appendingPathComponent(league.folder)
        try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        guard let url = URL(string: league.endpoint) else { continue }
        let sema = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: url) { data, _, _ in
            defer { sema.signal() }
            guard let data = data,
                  let teams = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                print("Failed to fetch or parse teams for \(league.name)")
                return
            }
            for team in teams {
                guard let name = team["Name"] as? String else { continue }
                let logoURLString = (team["WikipediaLogoUrl"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                    ?? (team["LogoUrl"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let logoURLStringUnwrapped = logoURLString, let logoURL = URL(string: logoURLStringUnwrapped), !logoURLStringUnwrapped.isEmpty else {
                    print("No logo for \(name)")
                    continue
                }
                let fileName = safeFileName(name) + ".png"
                let fileURL = folderURL.appendingPathComponent(fileName)
                let logoSema = DispatchSemaphore(value: 0)
                URLSession.shared.dataTask(with: logoURL) { logoData, _, _ in
                    defer { logoSema.signal() }
                    guard let logoData = logoData else {
                        print("Failed to download logo for \(name)")
                        return
                    }
                    do {
                        try logoData.write(to: fileURL)
                        print("Saved: \(fileName)")
                    } catch {
                        print("Failed to save logo for \(name): \(error)")
                    }
                }.resume()
                logoSema.wait()
            }
        }.resume()
        sema.wait()
    }
    print("\nAll logos fetched and saved.")
}

fetchAndSaveLogos()
