import SwiftUI

@main
struct DinghyWatchApp: App {
    @StateObject private var session = WatchSessionManager()
    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environmentObject(session)
        }
    }
}
