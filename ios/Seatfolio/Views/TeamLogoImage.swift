import SwiftUI

struct TeamLogoImage: View {
    let assetName: String
    var size: CGFloat = 40

    init(assetName: String, size: CGFloat = 40) {
        self.assetName = assetName
        self.size = size
    }

    init(league: String, teamID: String, size: CGFloat = 40) {
        self.assetName = TeamLogoHelper.assetName(league: league, teamID: teamID)
        self.size = size
    }

    var body: some View {
        Group {
            if let uiImage = resolveImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Circle().fill(Color(.tertiarySystemFill))
                    .overlay {
                        Image(systemName: "sportscourt.fill")
                            .font(.system(size: size * 0.4))
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .frame(width: size, height: size)
    }

    private func resolveImage() -> UIImage? {
        if let img = UIImage(named: assetName) { return img }
        let parts = assetName.split(separator: "/")
        if parts.count >= 2 {
            let dir = parts.dropLast().joined(separator: "/")
            let file = String(parts.last!)
            if let path = Bundle.main.path(forResource: file, ofType: "png", inDirectory: dir) {
                return UIImage(contentsOfFile: path)
            }
        }
        return nil
    }
}
