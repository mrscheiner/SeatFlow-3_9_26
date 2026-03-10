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
            VStack(spacing: 28) {
                Image("ChairLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(spinRotation))
                Text("Seatfolio")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                spinRotation = 360
            }
        }
    }
}
