import SwiftUI

struct AppLogoView: View {
    let size: CGFloat

    init(size: CGFloat = 60) {
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
    @State private var isSpinning: Bool = false

    init(size: CGFloat = 80, message: String = "Loading...") {
        self.size = size
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            Image("SeatfolioFullLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 1.25, height: size * 1.25)
                .clipShape(.rect(cornerRadius: size * 0.22))
                .rotation3DEffect(
                    .degrees(isSpinning ? 360 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                .animation(
                    .linear(duration: 2.0).repeatForever(autoreverses: false),
                    value: isSpinning
                )
                .onAppear {
                    isSpinning = true
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
    @State private var isSpinning: Bool = false

    var body: some View {
        Image("SeatfolioFullLogo")
            .resizable()
            .renderingMode(.original)
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .clipShape(.rect(cornerRadius: 44))
            .rotation3DEffect(
                .degrees(isSpinning ? 360 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(
                .linear(duration: 3.0).repeatForever(autoreverses: false),
                value: isSpinning
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .onAppear {
                isSpinning = true
            }
    }
}
