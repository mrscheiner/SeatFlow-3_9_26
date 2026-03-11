import SwiftUI

struct ContentView: View {
    @Environment(DataStore.self) private var store

    @State private var isLaunching = true
    @State private var splashRotation: Double = 0

    var body: some View {
        Group {
            if isLaunching {
                launchScreen
            } else if store.hasAnyPass {
                MainTabView()
            } else {
                SetupView()
            }
        }
        .task {
            store.restoreLastActivePass()

            try? await Task.sleep(for: .seconds(1.5))

            withAnimation {
                isLaunching = false
            }
        }
    }

    private var launchScreen: some View {
        ZStack {
            Color(red: 0/255, green: 31/255, blue: 63/255)
                .ignoresSafeArea()

            Image("SeatfolioFullLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 170, height: 170)
                .rotationEffect(.degrees(splashRotation))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                splashRotation = 360
            }
        }
    }
}
