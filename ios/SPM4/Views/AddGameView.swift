import SwiftUI

struct AddGameView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var opponent = ""
    @State private var date = Date()
    @State private var time = ""
    @State private var venueName = ""
    @State private var gameType: GameType = .regular
    @State private var isHome = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Opponent") {
                    TextField("Team Name", text: $opponent)
                }

                Section("Game Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Time (e.g. 7:00 PM)", text: $time)
                    TextField("Venue", text: $venueName)
                    Picker("Type", selection: $gameType) {
                        ForEach(GameType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    Toggle("Home Game", isOn: $isHome)
                }
            }
            .navigationTitle("Add Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addGame()
                        dismiss()
                    }
                    .disabled(opponent.isEmpty)
                }
            }
        }
    }

    private func addGame() {
        let gameNumber = (store.activePass?.games.count ?? 0) + 1
        let game = Game(
            date: date,
            opponent: opponent,
            venueName: venueName,
            time: time,
            gameNumber: gameNumber,
            type: gameType,
            isHome: isHome
        )
        store.addGame(game)
    }
}
