import SwiftUI

struct AppLogoView: View {
    let size: CGFloat

    init(size: CGFloat = 120) {
        self.size = size
    }

    var body: some View {
        Image("SeatfolioFullLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
}

struct SpinningLogoView: View {
    let size: CGFloat
    let message: String
    @State private var isPulsing: Bool = false

    init(size: CGFloat = 80, message: String = "Loading...") {
        self.size = size
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            Image("SeatfolioFullLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 2.5, height: size * 2.5)
                .scaleEffect(isPulsing ? 1.06 : 0.94)
                .opacity(isPulsing ? 1.0 : 0.7)
                .animation(
                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                    value: isPulsing
                )
                .onAppear {
                    isPulsing = true
                }

            if !message.isEmpty {
                Text(message)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct BottomLogoView: View {
    var body: some View {
        Image("SeatfolioFullLogo")
            .resizable()
            .renderingMode(.original)
            .aspectRatio(contentMode: .fit)
            .frame(width: 400, height: 400)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
    }
}
