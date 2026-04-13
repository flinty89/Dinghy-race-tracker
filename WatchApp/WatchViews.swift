import SwiftUI

struct WatchRootView: View {
    @EnvironmentObject var session: WatchSessionManager
    var body: some View {
        Group {
            if !session.isTracking {
                WatchReadyView()
            } else {
                WatchTrackingView()
            }
        }
        .background(Color.black)
    }
}

struct WatchReadyView: View {
    @EnvironmentObject var session: WatchSessionManager
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("⛵").font(.system(size: 36))
            Text("DINGHY\nTRACKER")
                .font(.system(size: 18, weight: .black))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            Spacer()
            Button(action: { session.startTracking() }) {
                Text("START")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0, green: 0.83, blue: 1))
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}

struct WatchTrackingView: View {
    @EnvironmentObject var session: WatchSessionManager
    @State private var showConfirm = false
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 5) {
                Circle().fill(Color.green).frame(width: 7, height: 7)
                Text("TRACKING")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.green)
                Spacer()
                Text(session.elapsedTime.watchFormatted)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(spacing: 0) {
                Text(String(format: "%.1f", session.currentSpeed))
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0, green: 0.83, blue: 1))
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                Text("KNOTS")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.gray)
            }
            Spacer()
            if showConfirm {
                Button(action: { session.stopTracking() }) {
                    Text("CONFIRM STOP")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: { showConfirm = true }) {
                    Text("FINISH")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color.black)
    }
}

extension TimeInterval {
    var watchFormatted: String {
        let m = Int(self) / 60
        let s = Int(self) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
