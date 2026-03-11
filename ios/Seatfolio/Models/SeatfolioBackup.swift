import Foundation

struct SeatfolioBackup: Codable {
    let version: Int
    let seasonPasses: [SeasonPass]
    let salesData: [String: [String: Sale]]
}

extension SeatfolioBackup {
    // Build nested salesData from flat [Sale]
    static func buildSalesData(from sales: [Sale]) -> [String: [String: Sale]] {
        var dict: [String: [String: Sale]] = [:]
        for sale in sales {
            let gameId = sale.gameId
            // Use a single key per game since pairId is not present
            dict[gameId, default: [:]]["default"] = sale
        }
        return dict
    }

    // Flatten nested salesData to flat [Sale]
    static func flattenSalesData(_ salesData: [String: [String: Sale]]) -> [Sale] {
        salesData.flatMap { (gameId, pairDict) in
            pairDict.map { (_, sale) in
                var s = sale
                s.gameId = gameId
                // pairId is not used
                return s
            }
        }
    }
}

// MARK: - Export Helper
func exportSeatfolioBackup(version: Int, seasonPasses: [SeasonPass], sales: [Sale]) throws -> Data {
    let backup = SeatfolioBackup(
        version: version,
        seasonPasses: seasonPasses,
        salesData: SeatfolioBackup.buildSalesData(from: sales)
    )
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return try encoder.encode(backup)
}

// MARK: - Import Helper
func importSeatfolioBackup(from data: Data) throws -> (version: Int, seasonPasses: [SeasonPass], sales: [Sale]) {
    let decoder = JSONDecoder()
    let backup = try decoder.decode(SeatfolioBackup.self, from: data)
    let sales = SeatfolioBackup.flattenSalesData(backup.salesData)
    return (backup.version, backup.seasonPasses, sales)
}
