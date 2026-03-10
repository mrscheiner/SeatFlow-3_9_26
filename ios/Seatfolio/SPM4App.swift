import SwiftUI

@main
struct SeatfolioApp: App {
    @State private var store: DataStore = DataStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
