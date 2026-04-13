import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: RaceStore
    @EnvironmentObject var gps: GPSService

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            HistoryView()
                .tabItem { Label("History", systemImage: "list.bullet.clipboard") }

            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.xyaxis.line") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Color.accentCyan)
        .onAppear { gps.requestPermission() }
    }
}
