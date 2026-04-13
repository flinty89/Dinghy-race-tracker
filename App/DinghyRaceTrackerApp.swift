import SwiftUI

@main
struct DinghyRaceTrackerApp: App {
    @StateObject private var store = RaceStore()
    @StateObject private var gps = GPSService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(gps)
                .preferredColorScheme(.dark)
        }
    }
}
