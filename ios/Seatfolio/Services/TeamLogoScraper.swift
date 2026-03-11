// TeamLogoScraper.swift
// Fetches and caches missing team logos for Seatfolio

import Foundation
import UIKit

class TeamLogoScraper {
    static let shared = TeamLogoScraper()
    private let cacheDirectory: URL
    private let leagues: [String: String] = [
        "NHL": "https://api.sportsdata.io/v3/nhl/scores/json/Teams",
        "NBA": "https://api.sportsdata.io/v3/nba/scores/json/Teams",
        "NFL": "https://api.sportsdata.io/v3/nfl/scores/json/Teams",
        "MLB": "https://api.sportsdata.io/v3/mlb/scores/json/Teams",
        "MLS": "https://api.sportsdata.io/v3/soccer/scores/json/Teams"
    ]
    private let apiKey = "YOUR_SPORTSDATAIO_API_KEY" // Replace with your actual key

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        cacheDirectory = appSupport.appendingPathComponent("teamLogos", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // Returns the local file URL for a team's logo
    func localLogoURL(for teamName: String) -> URL {
        let safeName = teamName.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "/", with: "_")
        return cacheDirectory.appendingPathComponent("\(safeName).png")
    }

    // Checks if a logo is cached locally
    func isLogoCached(for teamName: String) -> Bool {
        FileManager.default.fileExists(atPath: localLogoURL(for: teamName).path)
    }

    // Loads a logo image from cache if available
    func loadLogo(for teamName: String) -> UIImage? {
        let url = localLogoURL(for: teamName)
        return UIImage(contentsOfFile: url.path)
    }

    // Main entry: fetches and caches missing logos for all teams in the app
    func fetchMissingLogos(for teamNames: [String], completion: @escaping ([String]) -> Void) {
        let missingTeams = teamNames.filter { !isLogoCached(for: $0) }
        var stillMissing = Set(missingTeams)
        let group = DispatchGroup()

        for (league, endpoint) in leagues {
            group.enter()
            fetchLeagueTeams(from: endpoint) { teams in
                for team in teams {
                    guard let name = team["Name"] as? String else { continue }
                    if stillMissing.contains(name) {
                        if let urlString = team["WikipediaLogoUrl"] as? String ?? team["LogoUrl"] as? String,
                           let url = URL(string: urlString) {
                            self.downloadAndCacheLogo(from: url, for: name) { success in
                                if success { stillMissing.remove(name) }
                            }
                        }
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(Array(stillMissing))
        }
    }

    // Fetches team data from a league endpoint
    private func fetchLeagueTeams(from endpoint: String, completion: @escaping ([[String: Any]]) -> Void) {
        guard let url = URL(string: endpoint + "?key=\(apiKey)") else { completion([]); return }
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                completion([])
                return
            }
            completion(arr)
        }
        task.resume()
    }

    // Downloads and caches a logo image
    private func downloadAndCacheLogo(from url: URL, for teamName: String, completion: @escaping (Bool) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { completion(false); return }
            let fileURL = self.localLogoURL(for: teamName)
            do {
                try data.write(to: fileURL)
                completion(true)
            } catch {
                completion(false)
            }
        }
        task.resume()
    }

    // Generates a report of teams still missing logos
    func generateMissingLogoReport(for teamNames: [String]) -> [String] {
        let missing = teamNames.filter { !isLogoCached(for: $0) }
        print("\nMissing Logos Report\n--------------------")
        for name in missing { print(name) }
        return missing
    }
}
