import SwiftUI

struct ContentView: View {
    @Environment(DataStore.self) private var store
    @State private var isLaunching: Bool = true
    @State private var spinRotation: Double = 0

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
        .animation(.easeInOut(duration: 0.35), value: isLaunching)
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
            Color(hex: "001F3F")
                .ignoresSafeArea()
            Image("SeatfolioFullLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 170, height: 170)
                .scaleEffect(spinRotation == 0 ? 0.92 : 1.05)
                .opacity(spinRotation == 0 ? 0.75 : 1.0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                spinRotation = 1
            }
        }
    }
}
