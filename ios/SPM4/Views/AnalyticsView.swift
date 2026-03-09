import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(DataStore.self) private var store

    private var pass: SeasonPass? { store.activePass }

    private var allSeasonMonths: [(String, Double, Date)] {
        guard let pass else { return [] }
        let calendar = Calendar.current

        let allDates = pass.games.map(\.date) + pass.sales.map(\.soldDate)
        guard let earliest = allDates.min(), let latest = allDates.max() else { return [] }

        let salesGrouped = Dictionary(grouping: pass.sales) { sale in
            calendar.dateComponents([.year, .month], from: sale.soldDate)
        }

        var result: [(String, Double, Date)] = []
        var current = calendar.date(from: calendar.dateComponents([.year, .month], from: earliest)) ?? earliest
        let end = calendar.date(from: calendar.dateComponents([.year, .month], from: latest)) ?? latest

        while current <= end {
            let comps = calendar.dateComponents([.year, .month], from: current)
            let label = current.formatted(.dateTime.month(.abbreviated))
            let total = salesGrouped[comps]?.reduce(0) { $0 + $1.price } ?? 0
            result.append((label, total, current))
            guard let next = calendar.date(byAdding: .month, value: 1, to: current) else { break }
            current = next
        }
        return result
    }

    private var hasSalesData: Bool {
        allSeasonMonths.contains { $0.1 > 0 }
    }

    private var seatPairPerformance: [(SeatPair, Double, Int, Double)] {
        guard let pass else { return [] }
        return pass.seatPairs.map { pair in
            let sales = store.salesForSeatPair(section: pair.section, row: pair.row, seats: pair.seats)
            let revenue = sales.reduce(0) { $0 + $1.price }
            let gamesSold = Set(sales.map(\.gameId)).count
            let balance = revenue - pair.cost
            return (pair, revenue, gamesSold, balance)
        }
    }

    private var soldRate: Double {
        guard let pass, !pass.games.isEmpty, !pass.seatPairs.isEmpty else { return 0 }
        let totalPossible = pass.games.count * pass.seatPairs.count
        guard totalPossible > 0 else { return 0 }
        return Double(pass.totalSeatsSold) / Double(totalPossible) * 100
    }

    private var theme: TeamTheme { store.currentTheme }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    analyticsHeader

                    VStack(spacing: 20) {
                        overviewCards
                        revenueChart
                        seatPerformanceSection
                        seasonTotals
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    BottomLogoView()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Analytics")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private var analyticsHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let pass = store.activePass {
                HStack(spacing: 10) {
                    if let team = LeagueData.team(for: pass.teamId), let url = URL(string: team.logoURL) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fit)
                            } else {
                                Circle().fill(.white.opacity(0.2))
                            }
                        }
                        .frame(width: 36, height: 36)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pass.teamName)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("\(pass.seasonLabel) Season")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    Spacer()
                    let pnl = pass.netProfitLoss
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Net P/L")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.85))
                        Text(pnl, format: .currency(code: "USD"))
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [theme.primary, theme.secondary.opacity(0.6)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }

    private var overviewCards: some View {
        HStack(spacing: 12) {
            AnalyticCard(
                title: "Revenue",
                value: (pass?.totalRevenue ?? 0).formatted(.currency(code: "USD").precision(.fractionLength(0))),
                icon: "dollarsign.circle.fill",
                color: .green
            )
            AnalyticCard(
                title: "Seats Sold",
                value: "\(pass?.totalSeatsSold ?? 0)",
                icon: "ticket.fill",
                color: store.currentTheme.primary
            )
            AnalyticCard(
                title: "Sold Rate",
                value: "\(Int(soldRate))%",
                icon: "chart.pie.fill",
                color: .blue
            )
        }
    }

    private var revenueChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Revenue")
                .font(.headline)

            if allSeasonMonths.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                    Text("No schedule data yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 30)
            } else {
                let totalRev = allSeasonMonths.reduce(0) { $0 + $1.1 }
                Text(totalRev, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                ScrollView(.horizontal, showsIndicators: false) {
                    Chart {
                        ForEach(allSeasonMonths, id: \.2) { month, revenue, date in
                            BarMark(
                                x: .value("Month", month),
                                y: .value("Revenue", revenue),
                                width: .fixed(20)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [store.currentTheme.primary, store.currentTheme.secondary],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .clipShape(.rect(cornerRadius: 4, style: .continuous))
                            .annotation(position: .top, spacing: 4) {
                                if revenue > 0 {
                                    Text(revenue, format: .currency(code: "USD").precision(.fractionLength(0)))
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                if let val = value.as(Double.self) {
                                    Text("$\(Int(val))")
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                                .font(.caption)
                        }
                    }
                    .frame(width: max(CGFloat(allSeasonMonths.count) * 72, 280), height: 220)
                }
                .contentMargins(.horizontal, 4)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    private var seatPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Seat Pair Performance")
                .font(.headline)

            if seatPairPerformance.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chair.lounge")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                    Text("Add seat pairs to track performance")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                ForEach(seatPairPerformance, id: \.0.id) { pair, revenue, gamesSold, balance in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sec \(pair.section) Row \(pair.row)")
                                .font(.subheadline.weight(.medium))
                            Text("Seats: \(pair.seats)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(revenue, format: .currency(code: "USD"))
                                .font(.subheadline.weight(.semibold))
                            HStack(spacing: 8) {
                                Text("\(gamesSold) games")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(balance, format: .currency(code: "USD"))
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(balance >= 0 ? .green : .red)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    private var seasonTotals: some View {
        VStack(spacing: 12) {
            Text("Season Summary")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Text("Season Cost")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(pass?.totalSeasonCost ?? 0, format: .currency(code: "USD"))
                    .font(.body.weight(.medium))
            }

            HStack {
                Text("Sales to Date")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(pass?.totalRevenue ?? 0, format: .currency(code: "USD"))
                    .font(.body.weight(.medium))
                    .foregroundStyle(.green)
            }

            Divider()

            HStack {
                Text("Net P/L")
                    .font(.headline)
                Spacer()
                let pnl = pass?.netProfitLoss ?? 0
                Text(pnl, format: .currency(code: "USD"))
                    .font(.title3.bold())
                    .foregroundStyle(pnl >= 0 ? .green : .red)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

struct AnalyticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}
