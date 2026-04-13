import SwiftUI

extension Color {
    static let accentCyan    = Color(hex: "#00D4FF")
    static let navyBg        = Color(hex: "#0A0E1A")
    static let surface       = Color(hex: "#111827")
    static let surfaceAlt    = Color(hex: "#1A2235")
    static let borderColor   = Color(hex: "#1E2D45")
    static let mutedText     = Color(hex: "#4A6080")
    static let greenAccent   = Color(hex: "#00E676")
    static let orangeAccent  = Color(hex: "#FF9800")
    static let redAccent     = Color(hex: "#FF4444")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct StatTile: View {
    let label: String
    let value: String
    let unit: String
    var valueColor: Color = .white

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundColor(.mutedText)
            Text(value)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundColor(valueColor)
                .minimumScaleFactor(0.6)
            if !unit.isEmpty {
                Text(unit)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.mutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.surface)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borderColor, lineWidth: 1))
        .cornerRadius(14)
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .bold))
            .tracking(1.5)
            .foregroundColor(.mutedText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var color: Color = .accentCyan

    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.system(size: 18, weight: .black))
                .tracking(0.5)
                .foregroundColor(color == .accentCyan ? .black : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(color)
                .cornerRadius(14)
        }
    }
}

struct CardContainer<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(spacing: 0) { content }
            .background(Color.surface)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.borderColor, lineWidth: 1))
            .cornerRadius(16)
    }
}

struct LiveBadge: View {
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(Color.greenAccent).frame(width: 8, height: 8)
                .overlay(Circle().stroke(Color.greenAccent.opacity(0.4), lineWidth: 4))
            Text("LIVE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundColor(.greenAccent)
        }
    }
}

extension TimeInterval {
    var raceFormatted: String {
        let m = Int(self) / 60
        let s = Int(self) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
