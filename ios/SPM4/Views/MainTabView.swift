import SwiftUI

struct MainTabView: View {
    @Environment(DataStore.self) private var store
    @State private var selectedTab = 0

    var body: some View {
        @Bindable var store = store
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "house.fill", value: 0) {
                HomeView()
            }

            Tab("Schedule", systemImage: "calendar", value: 1) {
                ScheduleView()
            }

            Tab("Analytics", systemImage: "chart.bar.fill", value: 2) {
                AnalyticsView()
            }

            Tab("Events", systemImage: "ticket.fill", value: 3) {
                EventsView()
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 4) {
                SettingsView()
            }
        }
        .tint(store.currentTheme.primary)
        .toast(message: $store.toastMessage, isShowing: $store.showToast)
    }
}
