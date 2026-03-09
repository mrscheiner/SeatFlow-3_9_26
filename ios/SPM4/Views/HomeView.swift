import SwiftUI

struct HomeView: View {
    @Environment(DataStore.self) private var store
    @State private var showAddPass = false
    @State private var showEditPass = false

    private var pass: SeasonPass? { store.activePass }
    private var theme: TeamTheme { store.currentTheme }

    private var teamLogoURL: String? {
        guard let pass else { return nil }
        return LeagueData.team(for: pass.teamId)?.logoURL
    }

    private var recentSales: [Sale] {
        guard let pass else { return [] }
        return pass.sales.sorted { $0.soldDate > $1.soldDate }
    }

    private var totalSeats: Int {
        guard let pass else { return 0 }
        return pass.seatPairs.count * pass.games.count * 2
    }

    private var seatsSold: Int {
        guard let pass else { return 0 }
        return pass.sales.count * 2
    }

    private var avgPrice: Double {
        guard let pass, !pass.sales.isEmpty else { return 0 }
        return pass.totalRevenue / Double(pass.sales.count)
    }

    private var pendingCount: Int {
        guard let pass else { return 0 }
        return pass.sales.filter { $0.status == .pending }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if store.seasonPasses.count > 1 {
                        swipePassHeader
                    } else {
                        heroHeader
                    }

                    VStack(spacing: 16) {
                        statsGrid

                        if store.isLoadingSchedule {
                            loadingIndicator
                        } else if let error = store.scheduleError {
                            errorBanner(error)
                        }

                        if recentSales.isEmpty {
                            emptyState
                        } else {
                            recentSalesSection
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    BottomLogoView()
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddPass = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(.white)
                    }
                }
            }
            .toolbarBackground(theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showAddPass) {
                SetupView()
            }
            .sheet(isPresented: $showEditPass) {
                EditPassView()
            }

        }
    }

    private var seatfolioLogo: some View {
        Text("Seatfolio")
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .italic()
            .foregroundStyle(
                LinearGradient(
                    colors: [theme.textOnPrimary, theme.secondary.opacity(0.9)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
    }

    private var swipePassHeader: some View {
        VStack(spacing: 0) {
            seatfolioLogo
                .padding(.top, 12)
                .padding(.bottom, 4)

            TabView(selection: Binding(
                get: { store.activePassIndex },
                set: { newIndex in
                    store.activePassIndex = newIndex
                }
            )) {
                ForEach(Array(store.seasonPasses.enumerated()), id: \.element.id) { index, p in
                    passHeaderCard(for: p)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 200)

            Text("Swipe to switch passes")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.bottom, 6)
        }
        .background(
            LinearGradient(
                stops: [
                    .init(color: theme.primary, location: 0),
                    .init(color: theme.secondary.opacity(0.7), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private func passHeaderCard(for p: SeasonPass) -> some View {
        let pTheme = TeamThemeProvider.theme(for: p.teamId)
        let logoURL = LeagueData.team(for: p.teamId)?.logoURL

        return Button {
            showEditPass = true
        } label: {
            VStack(spacing: 12) {
                HStack(spacing: 14) {
                    if let logoURL, let url = URL(string: logoURL) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fit)
                            } else {
                                Circle().fill(.white.opacity(0.3))
                            }
                        }
                        .frame(width: 64, height: 64)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(p.teamName)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        Text("\(p.seasonLabel) Season")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.9))
                        Text("\(p.sales.count) sales • \(p.games.count) games")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.5))
                }

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total Revenue")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.9))
                        Text(p.totalRevenue, format: .currency(code: "USD"))
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Net P/L")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.9))
                        Text(p.netProfitLoss, format: .currency(code: "USD"))
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    stops: [
                        .init(color: pTheme.primary, location: 0),
                        .init(color: pTheme.secondary.opacity(0.7), location: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .buttonStyle(.plain)
    }

    private var heroHeader: some View {
        Button {
            showEditPass = true
        } label: {
            VStack(spacing: 12) {
                seatfolioLogo
                    .padding(.bottom, 2)

                HStack(spacing: 14) {
                    if let logoURL = teamLogoURL, let url = URL(string: logoURL) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fit)
                            } else {
                                Circle().fill(.white.opacity(0.3))
                            }
                        }
                        .frame(width: 64, height: 64)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(pass?.teamName ?? "No Pass")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        Text("\(pass?.seasonLabel ?? "") Season")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.9))
                        if let pass {
                            Text("\(pass.sales.count) sales • \(pass.games.count) games")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.5))
                }

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total Revenue")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.9))
                        Text(pass?.totalRevenue ?? 0, format: .currency(code: "USD"))
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Net P/L")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.9))
                        Text(pass?.netProfitLoss ?? 0, format: .currency(code: "USD"))
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    stops: [
                        .init(color: theme.primary, location: 0),
                        .init(color: theme.secondary.opacity(0.7), location: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .buttonStyle(.plain)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ], spacing: 10) {
            StatCard(
                icon: "dollarsign.circle.fill",
                iconColor: .green,
                title: "Revenue",
                value: (pass?.totalRevenue ?? 0).formatted(.currency(code: "USD").precision(.fractionLength(0))),
                subtitle: "\(seatsSold) seats sold"
            )

            StatCard(
                icon: "chair.lounge.fill",
                iconColor: theme.primary,
                title: "Seats Sold",
                value: "\(seatsSold)",
                subtitle: "of \(totalSeats) available"
            )

            StatCard(
                icon: "chart.line.uptrend.xyaxis",
                iconColor: .blue,
                title: "Avg Price",
                value: avgPrice.formatted(.currency(code: "USD").precision(.fractionLength(0))),
                subtitle: "per pair"
            )

            StatCard(
                icon: "clock.fill",
                iconColor: .red,
                title: "Pending",
                value: "\(pendingCount)",
                subtitle: "payments"
            )
        }
        .padding(.horizontal, 16)
    }

    private var loadingIndicator: some View {
        SpinningLogoView(size: 48, message: "Loading schedule...")
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal, 16)
    }

    private func errorBanner(_ error: String) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("Schedule Error")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button {
                    Task { await store.fetchScheduleFromAPI() }
                } label: {
                    Label("Retry", systemImage: "arrow.clockwise")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            Text(error)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "ticket")
                .font(.system(size: 44))
                .foregroundStyle(.tertiary)
            Text("No Sales Yet")
                .font(.title3.weight(.semibold))
            Text("Record a sale from the Schedule tab to start tracking.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .padding(.horizontal)
    }

    private var recentSalesSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Recent Sales")
                    .font(.title3.bold())
                Spacer()
                if recentSales.count > 5 {
                    Text("View All (\(recentSales.count))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)

            ForEach(Array(recentSales.prefix(10))) { sale in
                RecentSaleCard(
                    sale: sale,
                    leagueId: pass?.leagueId ?? "",
                    games: pass?.games ?? [],
                    theme: theme
                )
                .padding(.horizontal, 16)
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)

            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(subtitle)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}

struct RecentSaleCard: View {
    let sale: Sale
    let leagueId: String
    let games: [Game]
    let theme: TeamTheme

    private var game: Game? {
        games.first { $0.id == sale.gameId }
    }

    private var opponentLogoURL: String? {
        let effectiveLeague = sale.leagueId.isEmpty ? leagueId : sale.leagueId
        if !sale.opponentAbbr.isEmpty,
           let url = LeagueData.logoURLForAPIAbbr(sale.opponentAbbr, leagueId: effectiveLeague) {
            return url
        }
        if let game, !game.opponentAbbr.isEmpty,
           let url = LeagueData.logoURLForAPIAbbr(game.opponentAbbr, leagueId: effectiveLeague) {
            return url
        }
        if let found = findLogoByName(sale.opponent.isEmpty ? (game?.opponent ?? "") : sale.opponent, leagueId: effectiveLeague) {
            return found
        }
        return nil
    }

    private func findLogoByName(_ name: String, leagueId: String) -> String? {
        guard !name.isEmpty, let league = LeagueData.league(for: leagueId) else { return nil }
        let match = league.teams.first {
            name.localizedStandardContains($0.name) ||
            name.localizedStandardContains($0.city) ||
            $0.name.localizedStandardContains(name) ||
            "\($0.city) \($0.name)".localizedStandardContains(name)
        }
        return match?.logoURL
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let game {
                Text("Game #\(game.displayLabel) • \(game.formattedDate)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(theme.primary)
            }

            HStack(spacing: 12) {
                if let logoURL = opponentLogoURL, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fit)
                        } else {
                            opponentFallbackIcon
                        }
                    }
                    .frame(width: 40, height: 40)
                } else {
                    opponentFallbackIcon
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(sale.opponent.isEmpty ? "Unknown" : sale.opponent)
                        .font(.headline)
                    Text("Sec \(sale.section) • Row \(sale.row) • Seats \(sale.seats)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(sale.price, format: .currency(code: "USD"))
                        .font(.headline)

                    SaleStatusBadge(status: sale.status)
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }

    private var opponentFallbackIcon: some View {
        Circle().fill(Color(.tertiarySystemFill))
            .frame(width: 40, height: 40)
            .overlay {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
    }
}

struct SaleStatusBadge: View {
    let status: SaleStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch status {
        case .paid: return Color.green.opacity(0.15)
        case .pending: return Color.red.opacity(0.15)
        case .perSeat: return Color.orange.opacity(0.15)
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .paid: return .green
        case .pending: return .red
        case .perSeat: return .orange
        }
    }
}
