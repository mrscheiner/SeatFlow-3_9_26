import SwiftUI

struct GameDetailView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let game: Game

    @State private var showAddSale = false
    @State private var editingSale: Sale?

    private var theme: TeamTheme { store.currentTheme }

    private var sales: [Sale] {
        store.salesForGame(game.id)
    }

    private var seatPairs: [SeatPair] {
        store.activePass?.seatPairs ?? []
    }

    private var sellAsPairsOnly: Bool {
        store.activePass?.sellAsPairsOnly ?? true
    }

    private var isPast: Bool {
        game.date < Date.now
    }

    private var totalRevenue: Double {
        sales.reduce(0) { $0 + $1.price }
    }

    private var opponentLogoURL: String? {
        guard let pass = store.activePass else { return nil }
        if let teamId = game.opponentTeamId,
           let url = LeagueData.logoURLForTeamId(teamId, leagueId: pass.leagueId) {
            return url
        }
        return LeagueData.logoURLForAPIAbbr(game.opponentAbbr, leagueId: pass.leagueId)
    }

    private var fullOpponentName: String {
        guard let pass = store.activePass, !game.opponentAbbr.isEmpty else { return game.opponent }
        let name = LeagueData.teamNameForAPIAbbr(game.opponentAbbr, leagueId: pass.leagueId)
        return name == game.opponentAbbr ? game.opponent : name
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    gameHeader

                    VStack(spacing: 16) {
                        gameSummaryCards

                        if sales.isEmpty {
                            emptySalesState
                        } else {
                            salesSection
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSale = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showAddSale) {
                GameSaleEntryView(game: game)
            }
            .sheet(item: $editingSale) { sale in
                GameSaleEntryView(game: game, editingSale: sale)
            }
        }
    }

    private var gameHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                if let logoURL = opponentLogoURL, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fit)
                        } else {
                            Circle().fill(.white.opacity(0.2))
                        }
                    }
                    .frame(width: 56, height: 56)
                }

                VStack(alignment: .leading, spacing: 4) {
                    if !game.displayLabel.isEmpty {
                        Text("Game #\(game.displayLabel)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Text("vs \(fullOpponentName)")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    Text(game.formattedFullDate)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                    Text(TimezoneHelper.formatGameTime(game.date, teamId: store.activePass?.teamId ?? ""))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }

            HStack(spacing: 20) {
                VStack(spacing: 2) {
                    Text("Revenue")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    Text(totalRevenue, format: .currency(code: "USD"))
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
                VStack(spacing: 2) {
                    Text("Tickets Sold")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    Text("\(sales.count * 2)")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
                VStack(spacing: 2) {
                    Text("Available")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    let available = max(0, (seatPairs.count - sales.count) * 2)
                    Text("\(available)")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                stops: [
                    .init(color: theme.primary, location: 0),
                    .init(color: theme.primary.opacity(0.9), location: 0.5),
                    .init(color: theme.secondary.opacity(0.7), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .opacity(isPast ? 0.7 : 1.0)
    }

    private var gameSummaryCards: some View {
        HStack(spacing: 10) {
            let paidCount = sales.filter { $0.status == .paid }.count
            let pendingCount = sales.filter { $0.status == .pending }.count

            MiniStatCard(
                title: "Paid",
                value: "\(paidCount)",
                color: .green
            )
            MiniStatCard(
                title: "Pending",
                value: "\(pendingCount)",
                color: .red
            )
            MiniStatCard(
                title: sellAsPairsOnly ? "Pair Sale" : "Individual",
                value: sellAsPairsOnly ? "Yes" : "OK",
                color: theme.primary
            )
        }
        .padding(.horizontal, 16)
    }

    private var emptySalesState: some View {
        VStack(spacing: 16) {
            Image(systemName: "ticket")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text("No Sales for This Game")
                .font(.headline)
            Text("Tap + to record a ticket sale")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button {
                showAddSale = true
            } label: {
                Label("Add Sale", systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.primary)
        }
        .padding(30)
    }

    private var salesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sales")
                .font(.title3.bold())
                .padding(.horizontal, 16)

            ForEach(sales) { sale in
                Button {
                    editingSale = sale
                } label: {
                    GameSaleRow(sale: sale, theme: theme)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }
        }
    }
}

struct MiniStatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}

struct GameSaleRow: View {
    let sale: Sale
    let theme: TeamTheme

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sec \(sale.section) • Row \(sale.row)")
                    .font(.subheadline.weight(.medium))
                Text("Seats: \(sale.seats)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(sale.soldDate.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(sale.price, format: .currency(code: "USD"))
                    .font(.headline)

                Text(sale.status.rawValue)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(sale.status == .paid ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    .foregroundStyle(sale.status == .paid ? .green : .red)
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}

struct GameSaleEntryView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let game: Game
    @State private var selectedSeatPairId = ""
    @State private var price = ""
    @State private var isPaid = false
    @State private var editingSale: Sale?

    init(game: Game, editingSale: Sale? = nil) {
        self.game = game
        _editingSale = State(initialValue: editingSale)
    }

    private var seatPairs: [SeatPair] {
        store.activePass?.seatPairs ?? []
    }

    private var sellAsPairsOnly: Bool {
        store.activePass?.sellAsPairsOnly ?? true
    }

    private var theme: TeamTheme { store.currentTheme }

    private var gameSaleFullOpponentName: String {
        guard let pass = store.activePass, !game.opponentAbbr.isEmpty else { return game.opponent }
        let name = LeagueData.teamNameForAPIAbbr(game.opponentAbbr, leagueId: pass.leagueId)
        return name == game.opponentAbbr ? game.opponent : name
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("vs \(gameSaleFullOpponentName)")
                                .font(.headline)
                            Text(game.formattedFullDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Game")
                }

                Section {
                    if seatPairs.count == 1 {
                        let pair = seatPairs[0]
                        HStack {
                            Text("Sec \(pair.section), Row \(pair.row), Seats \(pair.seats)")
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(theme.primary)
                        }
                        .onAppear { selectedSeatPairId = pair.id }
                    } else {
                        Picker("Seat Pair", selection: $selectedSeatPairId) {
                            Text("Select seats").tag("")
                            ForEach(seatPairs) { pair in
                                Text("Sec \(pair.section), Row \(pair.row), Seats \(pair.seats)")
                                    .tag(pair.id)
                            }
                        }
                    }

                    if sellAsPairsOnly {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                            Text("Selling as pair — enter total for both seats")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Seats")
                }

                Section {
                    TextField("Total Sale Amount ($)", text: $price)
                        .keyboardType(.decimalPad)

                    VStack(spacing: 12) {
                        HStack {
                            Text("Payment Status")
                            Spacer()
                            Text(isPaid ? "Paid" : "Pending")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(isPaid ? .green : .red)
                        }

                        Toggle(isOn: $isPaid) {
                            EmptyView()
                        }
                        .toggleStyle(PaymentToggleStyle())
                    }
                } header: {
                    Text("Sale Details")
                }
            }
            .navigationTitle(editingSale == nil ? "Record Sale" : "Edit Sale")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSale()
                        dismiss()
                    }
                    .disabled(price.isEmpty || (seatPairs.count > 1 && selectedSeatPairId.isEmpty))
                }
            }
            .onAppear {
                if let sale = editingSale {
                    price = String(sale.price)
                    isPaid = sale.status == .paid
                    selectedSeatPairId = seatPairs.first { $0.section == sale.section && $0.row == sale.row }?.id ?? ""
                } else if seatPairs.count == 1 {
                    selectedSeatPairId = seatPairs[0].id
                }
            }
        }
    }

    private func saveSale() {
        guard let priceValue = Double(price) else { return }
        let pair = seatPairs.first { $0.id == selectedSeatPairId } ?? seatPairs.first
        guard let pair else { return }
        let status: SaleStatus = isPaid ? .paid : .pending

        if var existing = editingSale {
            existing.price = priceValue
            existing.status = status
            existing.section = pair.section
            existing.row = pair.row
            existing.seats = pair.seats
            store.updateSale(existing)
        } else {
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
        }
    }
}
