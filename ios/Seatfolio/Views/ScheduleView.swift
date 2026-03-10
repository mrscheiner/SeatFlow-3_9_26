import SwiftUI

struct ScheduleView: View {
    @Environment(DataStore.self) private var store
    @State private var searchText = ""
    @State private var selectedFilter: GameTypeFilter = .all
    @State private var expandedGameId: String?
    @State private var saleAmount = ""
    @State private var salePaid = false
    @State private var selectedSeatPairId = ""
    @State private var editingSaleInline: Sale?

    private enum GameTypeFilter: String, CaseIterable {
        case all = "All"
        case preseason = "Preseason"
        case regular = "Regular"
        case playoff = "Playoff"
    }

    private var theme: TeamTheme { store.currentTheme }

    private var games: [Game] {
        guard let pass = store.activePass else { return [] }
        var filtered = pass.games

        if selectedFilter != .all {
            let gameType: GameType = {
                switch selectedFilter {
                case .all: return .regular
                case .preseason: return .preseason
                case .regular: return .regular
                case .playoff: return .playoff
                }
            }()
            filtered = filtered.filter { $0.type == gameType }
        }

        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.opponent.localizedStandardContains(searchText)
            }
        }

        return filtered.sorted { $0.date < $1.date }
    }

    private var allGamesForPass: [Game] {
        guard let pass = store.activePass else { return [] }
        return pass.games
    }

    private var seatPairs: [SeatPair] {
        store.activePass?.seatPairs ?? []
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                scheduleHeader

                filterBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGroupedBackground))

                if store.isLoadingSchedule {
                    Spacer()
                    SpinningLogoView(size: 48, message: "Loading schedule...")
                    Spacer()
                } else if allGamesForPass.isEmpty {
                    emptySchedule
                } else if games.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 40))
                            .foregroundStyle(theme.primary.opacity(0.5))
                        Text("No \(selectedFilter.rawValue) Games")
                            .font(.title3.weight(.semibold))
                        Text("Try selecting a different filter.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(games) { game in
                                ScheduleGameCard(
                                    game: game,
                                    sales: store.salesForGame(game.id),
                                    totalSeatPairs: store.activePass?.seatPairs.count ?? 0,
                                    leagueId: store.activePass?.leagueId ?? "",
                                    theme: theme,
                                    isExpanded: expandedGameId == game.id,
                                    seatPairs: seatPairs,
                                    teamId: store.activePass?.teamId ?? "",
                                    onTap: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            if expandedGameId == game.id {
                                                expandedGameId = nil
                                                editingSaleInline = nil
                                            } else {
                                                expandedGameId = game.id
                                                editingSaleInline = nil
                                                saleAmount = ""
                                                salePaid = false
                                                if seatPairs.count == 1 {
                                                    selectedSeatPairId = seatPairs[0].id
                                                } else {
                                                    selectedSeatPairId = ""
                                                }
                                            }
                                        }
                                    },
                                    saleAmount: $saleAmount,
                                    salePaid: $salePaid,
                                    selectedSeatPairId: $selectedSeatPairId,
                                    onSave: {
                                        if let editing = editingSaleInline {
                                            updateExistingSale(editing, for: game)
                                        } else {
                                            saveSale(for: game)
                                        }
                                    },
                                    onToggleStatus: { sale in
                                        toggleSaleStatus(sale)
                                    },
                                    onEditSale: { sale in
                                        editingSaleInline = sale
                                        saleAmount = String(format: "%.0f", sale.price)
                                        salePaid = sale.status == .paid
                                        selectedSeatPairId = seatPairs.first { $0.section == sale.section && $0.row == sale.row }?.id ?? seatPairs.first?.id ?? ""
                                    },
                                    onDeleteSale: { sale in
                                        store.deleteSale(sale.id)
                                    },
                                    editingSaleId: editingSaleInline?.id
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 10)

                        BottomLogoView()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search opponents")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Schedule")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await store.fetchScheduleFromAPI() }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundStyle(.white)
                    }
                }
            }
            .task(id: store.activePassId) {
                guard let pass = store.activePass, pass.games.isEmpty, !store.isLoadingSchedule else { return }
                await store.fetchScheduleFromAPI()
            }
        }
    }

    private var scheduleHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let pass = store.activePass {
                HStack(spacing: 10) {
                    if let team = LeagueData.team(for: pass.teamId), let url = URL(string: team.logoURL) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fit)
                            } else {
                                Circle().fill(.white.opacity(0.3))
                            }
                        }
                        .frame(width: 36, height: 36)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pass.teamName)
                            .font(.headline)
                            .foregroundStyle(.white)
                        let totalSeats = pass.seatPairs.count * pass.games.count * 2
                        let seatsSold = pass.sales.count * 2
                        Text("\(seatsSold) seats sold of \(totalSeats) available")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [theme.primary, theme.secondary.opacity(0.6)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }

    private var filterBar: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(GameTypeFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }

    private var emptySchedule: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(theme.primary.opacity(0.6))

            Text("No Games Yet")
                .font(.title3.weight(.semibold))

            if let error = store.scheduleError {
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Tap sync to fetch your team's schedule.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task { await store.fetchScheduleFromAPI() }
            } label: {
                Label("Sync Schedule", systemImage: "arrow.triangle.2.circlepath")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.primary)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func saveSale(for game: Game) {
        guard let priceValue = Double(saleAmount), priceValue > 0 else { return }
        let pair = seatPairs.first { $0.id == selectedSeatPairId } ?? seatPairs.first
        guard let pair else { return }
        let status: SaleStatus = salePaid ? .paid : .pending

        let sale = Sale(
            gameId: game.id,
            opponent: game.opponent,
            opponentAbbr: game.opponentAbbr,
            leagueId: store.activePass?.leagueId ?? "",
            gameDate: game.date,
            section: pair.section,
            row: pair.row,
            seats: pair.seats,
            price: priceValue,
            status: status
        )
        store.addSale(sale)
        saleAmount = ""
        salePaid = false
        editingSaleInline = nil
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            expandedGameId = nil
        }
    }

    private func updateExistingSale(_ sale: Sale, for game: Game) {
        guard let priceValue = Double(saleAmount), priceValue > 0 else { return }
        let pair = seatPairs.first { $0.id == selectedSeatPairId } ?? seatPairs.first
        guard let pair else { return }
        var updated = sale
        updated.price = priceValue
        updated.status = salePaid ? .paid : .pending
        updated.section = pair.section
        updated.row = pair.row
        updated.seats = pair.seats
        store.updateSale(updated)
        saleAmount = ""
        salePaid = false
        editingSaleInline = nil
    }

    private func toggleSaleStatus(_ sale: Sale) {
        var updated = sale
        updated.status = sale.status == .paid ? .pending : .paid
        store.updateSale(updated)
    }
}

struct ScheduleGameCard: View {
    let game: Game
    let sales: [Sale]
    let totalSeatPairs: Int
    let leagueId: String
    let theme: TeamTheme
    let isExpanded: Bool
    let seatPairs: [SeatPair]
    let teamId: String
    let onTap: () -> Void
    @Binding var saleAmount: String
    @Binding var salePaid: Bool
    @Binding var selectedSeatPairId: String
    let onSave: () -> Void
    let onToggleStatus: (Sale) -> Void
    let onEditSale: (Sale) -> Void
    let onDeleteSale: (Sale) -> Void
    var editingSaleId: String?

    private var isPast: Bool {
        game.date < Date.now
    }

    private var ticketsSold: Int {
        sales.count * 2
    }

    private var ticketsAvailable: Int {
        max(0, totalSeatPairs * 2 - ticketsSold)
    }

    private var totalRevenue: Double {
        sales.reduce(0) { $0 + $1.price }
    }

    private var allPaid: Bool {
        !sales.isEmpty && sales.allSatisfy { $0.status == .paid }
    }

    private var opponentLogoURL: String? {
        LeagueData.logoURLForAPIAbbr(game.opponentAbbr, leagueId: leagueId)
    }

    private var localTime: String {
        TimezoneHelper.formatGameTime(game.date, teamId: teamId)
    }

    private var adaptiveTextColor: Color {
        .white
    }

    private var adaptiveSecondaryTextColor: Color {
        .white.opacity(0.9)
    }

    private var adaptiveTertiaryTextColor: Color {
        .white.opacity(0.7)
    }

    private var fullOpponentName: String {
        if !game.opponentAbbr.isEmpty {
            return LeagueData.teamNameForAPIAbbr(game.opponentAbbr, leagueId: leagueId)
        }
        return game.opponent
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                onTap()
            } label: {
                HStack(spacing: 14) {
                    VStack(spacing: 2) {
                        Text(game.date.formatted(.dateTime.month(.abbreviated)))
                            .font(.caption.weight(.bold))
                            .textCase(.uppercase)
                        Text(game.date.formatted(.dateTime.day()))
                            .font(.title.bold())
                    }
                    .foregroundStyle(adaptiveTextColor)
                    .frame(width: 52, height: 56)

                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 8) {
                            if let logoURL = opponentLogoURL, let url = URL(string: logoURL) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable().aspectRatio(contentMode: .fit)
                                    } else {
                                        Circle().fill(adaptiveTextColor.opacity(0.3))
                                    }
                                }
                                .frame(width: 28, height: 28)
                            }

                            if !game.displayLabel.isEmpty {
                                Text("#\(game.displayLabel)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(adaptiveTextColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(adaptiveTextColor.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }

                        Text(fullOpponentName)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(adaptiveTextColor)
                            .lineLimit(1)

                        Text(localTime)
                            .font(.subheadline)
                            .foregroundStyle(adaptiveSecondaryTextColor)

                        HStack(spacing: 8) {
                            Text("\(ticketsSold) sold • \(ticketsAvailable) avail")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(adaptiveSecondaryTextColor)
                            if totalRevenue > 0 {
                                Text(totalRevenue, format: .currency(code: "USD"))
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(adaptiveTextColor)
                            }
                        }
                    }

                    Spacer()

                    VStack(spacing: 6) {
                        if allPaid {
                            ScheduleStatusPill(text: "Paid", isPaid: true)
                        } else if !sales.isEmpty {
                            ScheduleStatusPill(text: "Pending", isPaid: false)
                        }

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(adaptiveTertiaryTextColor)
                    }
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 12) {
                    Divider()
                        .background(.white.opacity(0.3))

                    if !sales.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(sales) { sale in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Sec \(sale.section) • Row \(sale.row)")
                                            .font(.caption.weight(.medium))
                                            .foregroundStyle(adaptiveTextColor)
                                        Text("Seats: \(sale.seats)")
                                            .font(.caption2)
                                            .foregroundStyle(adaptiveSecondaryTextColor)
                                    }
                                    Spacer()
                                    Text(sale.price, format: .currency(code: "USD"))
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(adaptiveTextColor)
                                    Button {
                                        onToggleStatus(sale)
                                    } label: {
                                        Text(sale.status.rawValue)
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(sale.status == .paid ? .green : .red)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule()
                                                    .fill((sale.status == .paid ? Color.green : Color.red).opacity(0.2))
                                            )
                                    }
                                    Button {
                                        onEditSale(sale)
                                    } label: {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(adaptiveSecondaryTextColor)
                                    }
                                    Button {
                                        onDeleteSale(sale)
                                    } label: {
                                        Image(systemName: "trash.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(adaptiveTertiaryTextColor)
                                    }
                                }
                                .padding(.horizontal, 12)
                            }
                        }
                        .padding(.bottom, 8)
                    }

                    if ticketsAvailable > 0 || editingSaleId != nil {
                        VStack(spacing: 10) {
                            Text(editingSaleId != nil ? "Edit Sale" : "Record Sale")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(adaptiveSecondaryTextColor)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if seatPairs.count > 1 {
                                HStack(spacing: 8) {
                                    ForEach(seatPairs) { pair in
                                        Button {
                                            selectedSeatPairId = pair.id
                                        } label: {
                                            Text("Sec \(pair.section)")
                                                .font(.caption2.weight(.semibold))
                                                .foregroundStyle(selectedSeatPairId == pair.id ? adaptiveTextColor : adaptiveTertiaryTextColor)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(
                                                    selectedSeatPairId == pair.id
                                                        ? adaptiveTextColor.opacity(0.25)
                                                        : adaptiveTextColor.opacity(0.1)
                                                )
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }

                            HStack(spacing: 10) {
                                HStack {
                                    Text("$")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(adaptiveTertiaryTextColor)
                                    TextField("Amount", text: $saleAmount)
                                        .keyboardType(.decimalPad)
                                        .font(.subheadline)
                                        .foregroundStyle(adaptiveTextColor)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(adaptiveTextColor.opacity(0.15))
                                .clipShape(.rect(cornerRadius: 10))

                                HStack(spacing: 4) {
                                    Text("2")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(adaptiveTextColor)
                                    Image(systemName: "ticket.fill")
                                        .font(.caption2)
                                        .foregroundStyle(adaptiveSecondaryTextColor)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .background(adaptiveTextColor.opacity(0.15))
                                .clipShape(.rect(cornerRadius: 10))
                            }

                            HStack(spacing: 12) {
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        salePaid.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 0) {
                                        Text("Pending")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(!salePaid ? .white : adaptiveTertiaryTextColor)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(!salePaid ? Color.red.opacity(0.6) : Color.clear)
                                            .clipShape(.rect(cornerRadius: 8))

                                        Text("Paid")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(salePaid ? .white : adaptiveTertiaryTextColor)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(salePaid ? Color.green.opacity(0.6) : Color.clear)
                                            .clipShape(.rect(cornerRadius: 8))
                                    }
                                    .background(adaptiveTextColor.opacity(0.1))
                                    .clipShape(.rect(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)

                                Button {
                                    onSave()
                                } label: {
                                    Text(editingSaleId != nil ? "Update" : "Save")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(theme.primary)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color.white)
                                        .clipShape(.rect(cornerRadius: 10))
                                }
                                .disabled(saleAmount.isEmpty)
                                .opacity(saleAmount.isEmpty ? 0.5 : 1)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                    }
                }
            }
        }
        .background(
            LinearGradient(
                colors: theme.gradient,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
        .opacity(isPast && !isExpanded ? 0.85 : 1.0)
    }
}

struct ScheduleStatusPill: View {
    let text: String
    let isPaid: Bool

    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(isPaid ? .green : .red)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill((isPaid ? Color.green : Color.red).opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke((isPaid ? Color.green : Color.red).opacity(0.4), lineWidth: 1)
            )
    }
}
