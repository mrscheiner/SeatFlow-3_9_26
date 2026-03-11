import SwiftUI

struct SetupView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var step: SetupStep = .league
    @State private var selectedLeague: League?
    @State private var selectedTeam: Team?
    @State private var seasonLabel = ""
    @State private var seatPairs: [SeatPair] = []
    @State private var sellAsPairsOnly = true
    @State private var newSection = ""
    @State private var newRow = ""
    @State private var newSeats = ""
    @State private var newCost = ""

    private enum SetupStep {
        case league, team, seats
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepIndicator
                    .padding(.top, 8)

                Group {
                    switch step {
                    case .league:
                        leagueSelection
                    case .team:
                        teamSelection
                    case .seats:
                        seatPairSetup
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if store.hasAnyPass && step == .league {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: 12) {
            ForEach(0..<3) { index in
                Capsule()
                    .fill(index <= currentStepIndex ? Color(hex: "002B5C") : Color(.systemGray4))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }

    private var currentStepIndex: Int {
        switch step {
        case .league: return 0
        case .team: return 1
        case .seats: return 2
        }
    }

    private var leagueSelection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose Your\nLeague")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color(hex: "002B5C"))
                    .padding(.horizontal)

                Text("Select the league for your season tickets")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(LeagueData.allLeagues) { league in
                        Button {
                            withAnimation(.snappy) {
                                selectedLeague = league
                                step = .team
                            }
                        } label: {
                            VStack(spacing: 12) {
                                TeamLogoImage(assetName: TeamLogoHelper.assetNameForLeague(league.id), size: 100)

                                Text(league.shortName)
                                    .font(.title2.bold())
                                    .foregroundStyle(Color(hex: "002B5C"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var teamSelection: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(selectedLeague?.teams ?? []) { team in
                    Button {
                        withAnimation(.snappy) {
                            selectedTeam = team
                            seasonLabel = generateSeasonLabel()
                            step = .seats
                        }
                    } label: {
                        HStack(spacing: 14) {
                            if let league = selectedLeague {
                                TeamLogoImage(league: league.id, teamID: team.id, size: 44)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(team.city) \(team.name)")
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.primary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                                .font(.body.weight(.semibold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Select Team")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(.snappy) { step = .league }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
    }

    private var seatPairSetup: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Season Label")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    TextField("e.g. 2025-2026 Season", text: $seasonLabel)
                        .textFieldStyle(.roundedBorder)
                        .foregroundStyle(.primary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $sellAsPairsOnly) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sell as Pairs Only")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text(sellAsPairsOnly ? "Tickets sold as pairs — total price for both" : "Individual ticket sales allowed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(selectedTeam.map { Color(hex: $0.primaryColor) } ?? .blue)

                    Text("Seat Pairs")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    ForEach(seatPairs) { pair in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sec \(pair.section), Row \(pair.row)")
                                    .font(.body.weight(.medium))
                                Text("Seats: \(pair.seats)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(pair.cost, format: .currency(code: "USD"))
                                .font(.body.weight(.semibold))
                            Button(role: .destructive) {
                                withAnimation { seatPairs.removeAll { $0.id == pair.id } }
                            } label: {
                                Image(systemName: "trash")
                                    .font(.body)
                            }
                        }
                        .padding(12)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 10))
                    }

                    addSeatPairForm
                }

                Button {
                    createPass()
                } label: {
                    Text("Create Season Pass")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTeam.map { Color(hex: $0.primaryColor) } ?? .blue)
                .disabled(seatPairs.isEmpty || seasonLabel.isEmpty)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Add Seats")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(.snappy) { step = .team }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Team")
                    }
                }
            }
        }
    }

    private var addSeatPairForm: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Section")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    TextField("e.g. 101", text: $newSection)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Row")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    TextField("e.g. A", text: $newRow)
                        .textFieldStyle(.roundedBorder)
                }
            }
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Seats")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    TextField("e.g. 1-2", text: $newSeats)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cost")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    TextField("$0.00", text: $newCost)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                }
            }
            Button {
                addSeatPair()
            } label: {
                Label("Add Seat Pair", systemImage: "plus.circle.fill")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(newSection.isEmpty || newRow.isEmpty || newSeats.isEmpty || newCost.isEmpty)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func addSeatPair() {
        guard let cost = Double(newCost) else { return }
        let pair = SeatPair(section: newSection, row: newRow, seats: newSeats, cost: cost)
        withAnimation(.snappy) { seatPairs.append(pair) }
        newSection = ""
        newRow = ""
        newSeats = ""
        newCost = ""
    }

    private func generateSeasonLabel() -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())
        guard let league = selectedLeague else { return "\(year)-\(year)" }

        switch league.id {
        case "nhl", "nba":
            if month >= 7 {
                return "\(year)-\(year + 1)"
            } else {
                return "\(year - 1)-\(year)"
            }
        case "nfl":
            if month >= 7 {
                return "\(year)-\(year + 1)"
            } else {
                return "\(year - 1)-\(year)"
            }
        case "mlb":
            if month >= 3 {
                return "\(year)-\(year)"
            } else {
                return "\(year - 1)-\(year - 1)"
            }
        case "mls":
            return "\(year)-\(year)"
        default:
            return "\(year)-\(year)"
        }
    }

    private func createPass() {
        guard let league = selectedLeague, let team = selectedTeam else { return }
        let pass = SeasonPass(
            leagueId: league.id,
            teamId: team.id,
            teamName: "\(team.city) \(team.name)",
            seasonLabel: seasonLabel,
            seatPairs: seatPairs,
            sellAsPairsOnly: sellAsPairsOnly
        )
        store.createPass(pass)
        Task { await store.fetchScheduleFromAPI() }
        dismiss()
    }
}
