import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var message: String
    @Binding var isShowing: Bool

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isShowing {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text(message)
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .allowsHitTesting(false)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowing)
    }
}

extension View {
    func toast(message: Binding<String>, isShowing: Binding<Bool>) -> some View {
        modifier(ToastModifier(message: message, isShowing: isShowing))
    }
}
