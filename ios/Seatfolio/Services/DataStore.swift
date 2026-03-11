import Foundation
import SwiftUI

nonisolated enum ImportError: Error, LocalizedError, Sendable {
    case invalidData(String)
    case noActivePass

    var errorDescription: String? {
        switch self {
        case .invalidData(let detail): return "Invalid import file: \(detail)"
        case .noActivePass: return "No active season pass to import sales into"
        }
    }

nonisolated struct SalesWrapper: Codable, Sendable {
    let sales: [Sale]
}


}

@Observable
class DataStore {
                    func restoreBackup(_ passes: [SeasonPass], events: [StandaloneEvent]) {
                        self.seasonPasses = passes
                        self.appEvents = events
                        if let first = passes.first {
                            self.activePassId = first.id
                        }
                    }
                func deleteEvent(_ eventId: String) {
                    appEvents.removeAll { $0.id == eventId }
                }
            func createPass(_ pass: SeasonPass) {
                seasonPasses.append(pass)
                activePassId = pass.id
            }
        func addEvent(_ event: StandaloneEvent) {
            appEvents.append(event)
        }

        func updateEvent(_ event: StandaloneEvent) {
            if let idx = appEvents.firstIndex(where: { $0.id == event.id }) {
                appEvents[idx] = event
            }
        }
    func restoreLastActivePass() {
        let savedId = UserDefaults.standard.string(forKey: activePassKey)
        if let savedId, seasonPasses.contains(where: { $0.id == savedId }) {
            activePassId = savedId
        } else if let first = seasonPasses.first {
            activePassId = first.id
        }
    }

    var seasonPasses: [SeasonPass] = []
    var activePassId: String?
    var isLoadingSchedule = false
    var scheduleError: String?
    var toastMessage = ""
    var showToast = false
    var appEvents: [StandaloneEvent] = []

    var activePass: SeasonPass? {
        get { seasonPasses.first { $0.id == activePassId } }
        set {
            guard let newValue, let index = seasonPasses.firstIndex(where: { $0.id == newValue.id }) else { return }
            seasonPasses[index] = newValue
        }
    }

    var hasAnyPass: Bool { !seasonPasses.isEmpty }

    var currentTheme: TeamTheme {
        guard let pass = activePass else { return .default }
        return TeamThemeProvider.theme(for: pass.teamId)
    }

    private let passesKey = "spm4_season_passes"
    private let activePassKey = "spm4_active_pass_id"
    private let eventsKey = "spm4_app_events"

    private var isFetching = false
    private var fetchTaskId: String?
    private var saveTask: Task<Void, Never>?
    private var toastDismissTask: Task<Void, Never>?
    private var isDataLoaded = false

    init() {
        loadData()
    }

    func loadData() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        print("[DataStore] Loading passes from UserDefaults key: \(passesKey)")
        if let data = UserDefaults.standard.data(forKey: passesKey) {
            print("[DataStore] Found data for passesKey, size: \(data.count) bytes")
            do {
                let decoded = try decoder.decode([SeasonPass].self, from: data)
                print("[DataStore] Decoded \(decoded.count) passes")
                seasonPasses = decoded
            } catch {
                print("[DataStore] Failed to decode passes, attempting recovery: \(error.localizedDescription)")
                recoverCorruptedData(key: passesKey)
            }
        } else {
            print("[DataStore] No data found for passesKey")
        }

        if let data = UserDefaults.standard.data(forKey: eventsKey) {
            print("[DataStore] Found data for eventsKey, size: \(data.count) bytes")
            do {
                let decoded = try decoder.decode([StandaloneEvent].self, from: data)
                appEvents = decoded
            } catch {
                print("[DataStore] Failed to decode events, clearing: \(error.localizedDescription)")
                UserDefaults.standard.removeObject(forKey: eventsKey)
                appEvents = []
            }
        } else {
            print("[DataStore] No data found for eventsKey")
        }

        activePassId = UserDefaults.standard.string(forKey: activePassKey)
        print("[DataStore] Loaded activePassId: \(String(describing: activePassId))")
        if activePassId == nil || !seasonPasses.contains(where: { $0.id == activePassId }) {
            activePassId = seasonPasses.first?.id
            print("[DataStore] Set activePassId to first pass: \(String(describing: activePassId))")
        }

        print("[DataStore] Final seasonPasses count: \(seasonPasses.count)")
        isDataLoaded = true
    }

    private func recoverCorruptedData(key: String) {
        let backupKey = key + "_backup"
        if let backupData = UserDefaults.standard.data(forKey: backupKey) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let recovered = try? decoder.decode([SeasonPass].self, from: backupData) {
                seasonPasses = recovered
                print("[DataStore] Recovered \(recovered.count) passes from backup")
                return
            }
        }
        UserDefaults.standard.removeObject(forKey: key)
        seasonPasses = []
        print("[DataStore] No backup available, starting fresh")
    }

    func passIndex(for passId: String) -> Int? {
        seasonPasses.firstIndex { $0.id == passId }
    }

    var activePassIndex: Int {
        get {
            guard let id = activePassId else { return 0 }
            return seasonPasses.firstIndex { $0.id == id } ?? 0
        }
        set {
            guard newValue >= 0, newValue < seasonPasses.count else { return }
            let pass = seasonPasses[newValue]
            if activePassId != pass.id {
                activePassId = pass.id
            }
        }
    }

    func updatePass(_ pass: SeasonPass) {
        if let index = seasonPasses.firstIndex(where: { $0.id == pass.id }) {
            seasonPasses[index] = pass
        }
    }

    func addSale(_ sale: Sale) {
        guard activePass != nil else { return }
        guard var pass = activePass else { return }
        pass.sales.append(sale)
        updatePass(pass)
    }

    func updateSale(_ sale: Sale) {
        guard var passCheck = activePass else { return }
        if let idx = passCheck.sales.firstIndex(where: { $0.id == sale.id }) {
            guard var pass = activePass else { return }
            if let index = pass.sales.firstIndex(where: { $0.id == sale.id }) {
                pass.sales[index] = sale
                updatePass(pass)
            }
        }
    }

    func deleteSale(_ saleId: String) {
        guard let passCheck = activePass else { return }
        guard var pass = activePass else { return }
        pass.sales.removeAll { $0.id == saleId }
        updatePass(pass)
    }

    func addGame(_ game: Game) {
        guard var pass = activePass else { return }
        pass.games.append(game)
        updatePass(pass)
    }

    func setGames(_ games: [Game]) {
        guard var pass = activePass else { return }
        pass.games = games
        updatePass(pass)
    }

    func fetchScheduleFromAPI() async {
        guard !isFetching else {
            print("[DataStore] Fetch already in progress, skipping")
            return
        }

        guard let pass = activePass else {
            scheduleError = "No active pass selected"
            return
        }

        let currentFetchId = UUID().uuidString
        fetchTaskId = currentFetchId
        isFetching = true
        isLoadingSchedule = true
        scheduleError = nil

        defer {
            if fetchTaskId == currentFetchId {
                isFetching = false
                isLoadingSchedule = false
            }
        }

        do {
            guard let team = LeagueData.team(for: pass.teamId) else {
                scheduleError = "Team '\(pass.teamId)' not found in league data"
                return
            }

            let season = SportsDataService.shared.seasonString(for: pass.leagueId, from: pass.seasonLabel)

            let games = try await SportsDataService.shared.fetchSchedule(
                leagueId: pass.leagueId,
                teamAbbr: team.apiAbbr,
                season: season
            )

            guard fetchTaskId == currentFetchId else {
                print("[DataStore] Fetch result discarded — pass changed during fetch")
                return
            }

            setGames(games)
            scheduleError = nil
        } catch {
            guard fetchTaskId == currentFetchId else { return }
            scheduleError = error.localizedDescription
        }
    }

    func cancelFetch() {
        fetchTaskId = nil
        isFetching = false
        isLoadingSchedule = false
    }

    func importJSON(_ jsonString: String) throws -> String {
        guard let data = jsonString.data(using: .utf8) else {
            throw ImportError.invalidData("File could not be read as text")
        }

        // Try canonical SeatfolioBackup format first
        if let (version, passes, sales) = try? importSeatfolioBackup(from: data) {
            // Replace all passes and sales with imported data
            self.seasonPasses = passes
            // Optionally, set activePassId to the first pass
            self.activePassId = passes.first?.id
            return "Imported backup: version \(version), passes: \(passes.count), sales: \(sales.count)"
        }

        // If not recognized, throw error
        throw ImportError.invalidData("Unrecognized file format. Expected a Seatfolio backup file.")
    }



    func salesForGame(_ gameId: String) -> [Sale] {
        activePass?.sales.filter { $0.gameId == gameId } ?? []
    }

    func revenueForGame(_ gameId: String) -> Double {
        salesForGame(gameId).reduce(0) { $0 + $1.price }
    }

    func salesForSeatPair(section: String, row: String, seats: String) -> [Sale] {
        activePass?.sales.filter { $0.section == section && $0.row == row && $0.seats == seats } ?? []
    }
}
