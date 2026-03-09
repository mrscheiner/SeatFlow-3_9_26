import Foundation
import SwiftUI

@Observable
class DataStore {
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

        if let data = UserDefaults.standard.data(forKey: passesKey) {
            do {
                let decoded = try decoder.decode([SeasonPass].self, from: data)
                seasonPasses = decoded
            } catch {
                print("[DataStore] Failed to decode passes, attempting recovery: \(error.localizedDescription)")
                recoverCorruptedData(key: passesKey)
            }
        }

        if let data = UserDefaults.standard.data(forKey: eventsKey) {
            do {
                let decoded = try decoder.decode([StandaloneEvent].self, from: data)
                appEvents = decoded
            } catch {
                print("[DataStore] Failed to decode events, clearing: \(error.localizedDescription)")
                UserDefaults.standard.removeObject(forKey: eventsKey)
                appEvents = []
            }
        }

        activePassId = UserDefaults.standard.string(forKey: activePassKey)
        if activePassId == nil || !seasonPasses.contains(where: { $0.id == activePassId }) {
            activePassId = seasonPasses.first?.id
        }

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

    func save() {
        guard isDataLoaded else { return }

        saveTask?.cancel()

        saveTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled else { return }
            self?.performSave()
        }
    }

    private func performSave() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let data = try? encoder.encode(seasonPasses) {
            UserDefaults.standard.set(data, forKey: passesKey)
            UserDefaults.standard.set(data, forKey: passesKey + "_backup")
        }
        if let data = try? encoder.encode(appEvents) {
            UserDefaults.standard.set(data, forKey: eventsKey)
        }
        if let id = activePassId {
            UserDefaults.standard.set(id, forKey: activePassKey)
        } else {
            UserDefaults.standard.removeObject(forKey: activePassKey)
        }
    }

    private func saveImmediate() {
        guard isDataLoaded else { return }
        saveTask?.cancel()
        performSave()
    }

    func showToastMessage(_ message: String) {
        toastDismissTask?.cancel()
        toastMessage = message
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showToast = true
        }
        toastDismissTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                self?.showToast = false
            }
        }
    }

    func createPass(_ pass: SeasonPass) {
        seasonPasses.append(pass)
        activePassId = pass.id
        saveImmediate()
        showToastMessage("Pass created")
    }

    func deletePass(_ passId: String) {
        let name = seasonPasses.first { $0.id == passId }?.teamName ?? "Pass"
        seasonPasses.removeAll { $0.id == passId }
        if activePassId == passId {
            activePassId = seasonPasses.first?.id
        }
        saveImmediate()
        showToastMessage("Deleted: \(name)")
    }

    func switchToPass(_ passId: String) {
        guard activePassId != passId else { return }
        activePassId = passId
        saveImmediate()
    }

    func restoreLastActivePass() {
        let savedId = UserDefaults.standard.string(forKey: activePassKey)
        if let savedId, seasonPasses.contains(where: { $0.id == savedId }) {
            activePassId = savedId
        } else if let first = seasonPasses.first {
            activePassId = first.id
            saveImmediate()
        }
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
                save()
            }
        }
    }

    func updatePass(_ pass: SeasonPass) {
        if let index = seasonPasses.firstIndex(where: { $0.id == pass.id }) {
            seasonPasses[index] = pass
            save()
        }
    }

    func addSale(_ sale: Sale) {
        guard activePass != nil else { return }
        snapshotBeforeChange(label: "Before adding \(sale.price.formatted(.currency(code: "USD"))) sale for \(sale.opponent)")
        guard var pass = activePass else { return }
        pass.sales.append(sale)
        updatePass(pass)
        showToastMessage("Sale saved")
    }

    func updateSale(_ sale: Sale) {
        guard var passCheck = activePass else { return }
        if let idx = passCheck.sales.firstIndex(where: { $0.id == sale.id }) {
            let oldPrice = passCheck.sales[idx].price
            snapshotBeforeChange(label: "Before updating \(sale.opponent) sale from \(oldPrice.formatted(.currency(code: "USD"))) to \(sale.price.formatted(.currency(code: "USD")))")
            guard var pass = activePass else { return }
            if let index = pass.sales.firstIndex(where: { $0.id == sale.id }) {
                pass.sales[index] = sale
                updatePass(pass)
                showToastMessage("Sale updated")
            }
        }
    }

    func deleteSale(_ saleId: String) {
        guard let passCheck = activePass else { return }
        let sale = passCheck.sales.first { $0.id == saleId }
        if let sale {
            snapshotBeforeChange(label: "Before deleting \(sale.price.formatted(.currency(code: "USD"))) sale for \(sale.opponent)")
        }
        guard var pass = activePass else { return }
        pass.sales.removeAll { $0.id == saleId }
        updatePass(pass)
        showToastMessage("Sale deleted")
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

    // MARK: - App-Level Events

    func addEvent(_ event: StandaloneEvent) {
        snapshotBeforeChange(label: "Before adding event: \(event.eventName)")
        appEvents.append(event)
        save()
        showToastMessage("Event saved")
    }

    func updateEvent(_ event: StandaloneEvent) {
        if appEvents.contains(where: { $0.id == event.id }) {
            snapshotBeforeChange(label: "Before updating event: \(event.eventName)")
            if let index = appEvents.firstIndex(where: { $0.id == event.id }) {
                appEvents[index] = event
            }
            save()
        }
    }

    func deleteEvent(_ eventId: String) {
        let event = appEvents.first { $0.id == eventId }
        if let event {
            snapshotBeforeChange(label: "Before deleting event: \(event.eventName)")
        }
        appEvents.removeAll { $0.id == eventId }
        save()
        showToastMessage("Event deleted")
    }

    func createBackup(label: String) {
        guard var pass = activePass else { return }
        let backup = Backup(
            label: label,
            salesCount: pass.sales.count,
            eventsCount: appEvents.count,
            salesData: pass.sales,
            eventsData: appEvents,
            gamesData: pass.games
        )
        pass.backups.append(backup)
        updatePass(pass)
    }

    private func snapshotBeforeChange(label: String) {
        guard var pass = activePass else { return }
        let backup = Backup(
            label: label,
            salesCount: pass.sales.count,
            eventsCount: appEvents.count,
            salesData: pass.sales,
            eventsData: appEvents,
            gamesData: pass.games
        )
        if pass.backups.count > 50 {
            pass.backups.removeFirst(pass.backups.count - 50)
        }
        pass.backups.append(backup)
        if let index = seasonPasses.firstIndex(where: { $0.id == pass.id }) {
            seasonPasses[index] = pass
        }
    }

    func restoreBackup(_ backup: Backup) {
        guard var pass = activePass else { return }
        pass.sales = backup.salesData
        appEvents = backup.eventsData
        pass.games = backup.gamesData
        updatePass(pass)
    }

    func exportJSON() -> String? {
        guard let pass = activePass else { return nil }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(pass) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func exportCSV() -> String? {
        guard let pass = activePass else { return nil }
        var csv = "Game,Opponent,Date,Section,Row,Seats,Price,Sold Date,Status\n"
        for sale in pass.sales {
            let dateStr = sale.gameDate.formatted(.dateTime.month().day().year())
            let soldStr = sale.soldDate.formatted(.dateTime.month().day().year())
            csv += "\(sale.gameId),\(sale.opponent),\(dateStr),\(sale.section),\(sale.row),\(sale.seats),\(sale.price),\(soldStr),\(sale.status.rawValue)\n"
        }
        return csv
    }

    func importJSON(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else { return false }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let pass = try? decoder.decode(SeasonPass.self, from: data) else { return false }
        if let index = seasonPasses.firstIndex(where: { $0.id == pass.id }) {
            seasonPasses[index] = pass
        } else {
            seasonPasses.append(pass)
            activePassId = pass.id
        }
        saveImmediate()
        showToastMessage("Data imported")
        return true
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
