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
}

nonisolated struct SalesWrapper: Codable, Sendable {
    let sales: [Sale]
}

nonisolated struct ExternalBackup: Codable, Sendable {
    let version: String?
    let createdAtISO: String?
    let activeSeasonPassId: String?
    let seasonPasses: [ExternalSeasonPass]
}

nonisolated struct ExternalSeasonPass: Codable, Sendable {
    let id: String
    let leagueId: String
    let teamId: String
    let teamName: String
    let seasonLabel: String
    let seatPairs: [ExternalSeatPair]
    let salesData: [String: [String: ExternalSale]]?
    let games: [ExternalGame]?
}

nonisolated struct ExternalSeatPair: Codable, Sendable {
    let id: String
    let section: String
    let row: String
    let seats: String
    let seasonCost: Double?
    let cost: Double?

    var resolvedCost: Double {
        seasonCost ?? cost ?? 0
    }
}

nonisolated struct ExternalSale: Codable, Sendable {
    let id: String
    let gameId: String
    let pairId: String?
    let section: String
    let row: String
    let seats: String
    let seatCount: Int?
    let price: Double
    let paymentStatus: String?
    let status: String?
    let soldDate: String
    let opponentLogo: String?
}

nonisolated struct ExternalGame: Codable, Sendable {
    let id: String
    let date: String?
    let opponent: String?
    let time: String?
    let type: String?
    let gameNumber: String?
    let dateTimeISO: String?
}

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

    func importJSON(_ jsonString: String) throws -> String {
        guard let data = jsonString.data(using: .utf8) else {
            throw ImportError.invalidData("File could not be read as text")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Try 1: External backup format (nested salesData dict, seasonCost, etc.)
        if let backup = try? decoder.decode(ExternalBackup.self, from: data), !backup.seasonPasses.isEmpty {
            return try importExternalBackup(backup)
        }

        // Try 2: Decode as a full SeasonPass (native format)
        if let pass = try? decoder.decode(SeasonPass.self, from: data) {
            if let index = seasonPasses.firstIndex(where: { $0.id == pass.id }) {
                seasonPasses[index] = pass
                saveImmediate()
                return "Imported \(pass.sales.count) sales for \(pass.teamName)"
            } else {
                seasonPasses.append(pass)
                activePassId = pass.id
                saveImmediate()
                return "Imported pass: \(pass.teamName) with \(pass.sales.count) sales"
            }
        }

        // Try 3: Decode as an array of Sales and merge into active pass
        if let sales = try? decoder.decode([Sale].self, from: data) {
            guard var pass = activePass else {
                throw ImportError.noActivePass
            }
            let existingIds = Set(pass.sales.map { $0.id })
            let newSales = sales.filter { !existingIds.contains($0.id) }
            if newSales.isEmpty && !sales.isEmpty {
                pass.sales = sales
                updatePass(pass)
                return "Updated \(sales.count) existing sales for \(pass.teamName)"
            } else {
                pass.sales.append(contentsOf: newSales)
                updatePass(pass)
                return "Added \(newSales.count) sales to \(pass.teamName)"
            }
        }

        // Try 4: Decode as a wrapper object with a "sales" key
        if let wrapper = try? decoder.decode(SalesWrapper.self, from: data) {
            guard var pass = activePass else {
                throw ImportError.noActivePass
            }
            let existingIds = Set(pass.sales.map { $0.id })
            let newSales = wrapper.sales.filter { !existingIds.contains($0.id) }
            if newSales.isEmpty && !wrapper.sales.isEmpty {
                pass.sales = wrapper.sales
                updatePass(pass)
                return "Updated \(wrapper.sales.count) existing sales for \(pass.teamName)"
            } else {
                pass.sales.append(contentsOf: newSales)
                updatePass(pass)
                return "Added \(newSales.count) sales to \(pass.teamName)"
            }
        }

        throw ImportError.invalidData("Unrecognized file format. Expected a Seatfolio backup or sales data file.")
    }

    private func importExternalBackup(_ backup: ExternalBackup) throws -> String {
        var totalSalesImported = 0
        var passesImported: [String] = []

        for extPass in backup.seasonPasses {
            let seatPairs = extPass.seatPairs.map { sp in
                SeatPair(id: sp.id, section: sp.section, row: sp.row, seats: sp.seats, cost: sp.resolvedCost)
            }

            let sales = flattenSalesData(extPass.salesData, leagueId: extPass.leagueId, games: extPass.games)
            let games = convertExternalGames(extPass.games, leagueId: extPass.leagueId)

            if let index = seasonPasses.firstIndex(where: {
                $0.teamId == extPass.teamId && $0.leagueId == extPass.leagueId
            }) {
                var existingPass = seasonPasses[index]
                existingPass.seatPairs = seatPairs
                existingPass.sales = sales
                if !games.isEmpty {
                    existingPass.games = games
                }
                seasonPasses[index] = existingPass
                totalSalesImported += sales.count
                passesImported.append(existingPass.teamName)
            } else {
                let newPass = SeasonPass(
                    id: extPass.id,
                    leagueId: extPass.leagueId,
                    teamId: extPass.teamId,
                    teamName: extPass.teamName,
                    seasonLabel: extPass.seasonLabel,
                    seatPairs: seatPairs,
                    sales: sales,
                    games: games
                )
                seasonPasses.append(newPass)
                activePassId = newPass.id
                totalSalesImported += sales.count
                passesImported.append(newPass.teamName)
            }
        }

        saveImmediate()

        let teamNames = passesImported.joined(separator: ", ")
        return "Imported \(totalSalesImported) sales for \(teamNames)"
    }

    private func flattenSalesData(_ salesData: [String: [String: ExternalSale]]?, leagueId: String, games: [ExternalGame]?) -> [Sale] {
        guard let salesData else { return [] }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let isoFormatterNoFrac = ISO8601DateFormatter()
        isoFormatterNoFrac.formatOptions = [.withInternetDateTime]

        let gameDateMap: [String: Date] = {
            guard let games else { return [:] }
            var map: [String: Date] = [:]
            for game in games {
                if let iso = game.dateTimeISO,
                   let d = isoFormatter.date(from: iso) ?? isoFormatterNoFrac.date(from: iso) {
                    map[game.id] = d
                }
            }
            return map
        }()

        let gameOpponentMap: [String: String] = {
            guard let games else { return [:] }
            var map: [String: String] = [:]
            for game in games {
                if let opp = game.opponent {
                    map[game.id] = opp.replacingOccurrences(of: "vs ", with: "")
                }
            }
            return map
        }()

        var result: [Sale] = []

        for (gameId, pairSales) in salesData {
            for (_, extSale) in pairSales {
                let soldDate = isoFormatter.date(from: extSale.soldDate)
                    ?? isoFormatterNoFrac.date(from: extSale.soldDate)
                    ?? Date()

                let gameDate = gameDateMap[gameId] ?? soldDate
                let opponent = gameOpponentMap[gameId] ?? ""

                let statusRaw = extSale.paymentStatus ?? extSale.status ?? "Pending"
                let status: SaleStatus = statusRaw.lowercased() == "paid" ? .paid : .pending

                let sale = Sale(
                    id: extSale.id,
                    gameId: gameId,
                    opponent: opponent,
                    opponentAbbr: "",
                    leagueId: leagueId,
                    gameDate: gameDate,
                    section: extSale.section,
                    row: extSale.row,
                    seats: extSale.seats,
                    price: extSale.price,
                    soldDate: soldDate,
                    status: status
                )
                result.append(sale)
            }
        }

        return result.sorted { $0.gameDate < $1.gameDate }
    }

    private func convertExternalGames(_ games: [ExternalGame]?, leagueId: String) -> [Game] {
        guard let games else { return [] }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let isoFormatterNoFrac = ISO8601DateFormatter()
        isoFormatterNoFrac.formatOptions = [.withInternetDateTime]

        var result: [Game] = []

        for extGame in games {
            let date: Date = {
                if let iso = extGame.dateTimeISO {
                    return isoFormatter.date(from: iso) ?? isoFormatterNoFrac.date(from: iso) ?? Date()
                }
                return Date()
            }()

            let opponent = (extGame.opponent ?? "").replacingOccurrences(of: "vs ", with: "")

            let gameType: GameType = {
                let t = (extGame.type ?? "").lowercased()
                if t.contains("pre") { return .preseason }
                if t.contains("play") || t.contains("post") { return .playoff }
                return .regular
            }()

            let gameLabel: String = {
                guard let num = extGame.gameNumber else { return "" }
                let trimmed = num.trimmingCharacters(in: .whitespaces)
                if trimmed.lowercased().hasPrefix("ps") {
                    return "PS\(trimmed.dropFirst(2).trimmingCharacters(in: .whitespaces))"
                }
                return trimmed
            }()

            let gameNumber: Int = {
                guard let num = extGame.gameNumber else { return 0 }
                let digits = num.filter { $0.isNumber }
                return Int(digits) ?? 0
            }()

            let game = Game(
                id: extGame.id,
                date: date,
                opponent: opponent,
                time: extGame.time ?? "",
                gameNumber: gameNumber,
                gameLabel: gameLabel,
                type: gameType,
                isHome: true
            )
            result.append(game)
        }

        return result.sorted { $0.date < $1.date }
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
