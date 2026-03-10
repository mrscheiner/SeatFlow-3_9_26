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
    @State private var rotation: Double = 0

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
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        rotation = 360
                    }
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
    @State private var rotation: Double = 0

    var body: some View {
        Image("SeatfolioFullLogo")
            .resizable()
            .renderingMode(.original)
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .clipShape(.rect(cornerRadius: 44))
            .rotationEffect(.degrees(rotation))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2)) {
                    rotation = 360
                }
            }
    }
}
