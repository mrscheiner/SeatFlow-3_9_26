import SwiftUI

struct AppLogoView: View {
    let size: CGFloat

    init(size: CGFloat = 60) {
        self.size = size
    }

    var body: some View {
        Image("AppLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
}

struct SpinningLogoView: View {
    let size: CGFloat
    let message: String
    @State private var rotation: Double = 0

    init(size: CGFloat = 56, message: String = "Loading...") {
        self.size = size
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
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
    var body: some View {
        Image("AppLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 180, height: 180)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
    }
}
