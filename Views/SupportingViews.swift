import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: RaceStore
    var body: some View {
        NavigationStack {
            ZStack {
                Color.navyBg.ignoresSafeArea()
                Group {
                    if store.races.isEmpty {
                        VStack(spacing: 12) {
                            Text("⛵").font(.system(size: 48))
                            Text("No races yet")
                                .font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                            Text("Complete a race to see it here")
                                .font(.system(size: 14)).foregroundColor(.mutedText)
                        }
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("RACE HISTORY")
                                    .font(.system(size: 30, weight: .black)).foregroundColor(.white)
                                    .padding(.horizontal)
                                CardContainer {
                                    ForEach(store.races) { race in
                                        NavigationLink(destination: RaceDetailView(race: race)) {
                                            RaceListRow(race: race)
                                        }
                                        if race.id != store.races.last?.id {
                                            Divider().background(Color.borderColor)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                Spacer(minLength: 40)
                            }
                            .padding(.top, 16)
                        }
                    }
                }
            }
        }
    }
}

struct RaceListRow: View {
    let race: Race
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(race.name)
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                Text("\(race.date.formatted(date: .abbreviated, time: .omitted)) · \(race.boat.boatClass.rawValue)")
                    .font(.system(size: 12)).foregroundColor(.mutedText)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(String(format: "%.1f", race.maxSpeed))
                    .font(.system(size: 22, weight: .black, design: .rounded)).foregroundColor(.accentCyan)
                Text("kts max").font(.system(size: 11)).foregroundColor(.mutedText)
                Text(race.duration?.raceFormatted ?? "—")
                    .font(.system(size: 12)).foregroundColor(.mutedText)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}

struct RaceDetailView: View {
    @EnvironmentObject var store: RaceStore
    let race: Race
    var body: some View {
        ZStack {
            Color.navyBg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(race.name)
                            .font(.system(size: 26, weight: .black)).foregroundColor(.white)
                        Text("\(race.date.formatted(date: .long, time: .omitted)) · \(race.boat.boatClass.rawValue)")
                            .font(.system(size: 13)).foregroundColor(.mutedText)
                    }
                    .padding(.horizontal)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        StatTile(label: "Max Speed", value: String(format: "%.1f", race.maxSpeed), unit: "kts", valueColor: .accentCyan)
                        StatTile(label: "Avg Speed", value: String(format: "%.1f", race.avgSpeed), unit: "kts")
                        StatTile(label: "Race Time", value: race.duration?.raceFormatted ?? "—", unit: "mm:ss")
                        StatTile(label: "Tacks", value: "\(race.tackCount)", unit: "", valueColor: .greenAccent)
                        StatTile(label: "Jibes", value: "\(race.jibeCount)", unit: "", valueColor: .orangeAccent)
                        StatTile(label: "Laps", value: "\(race.laps.count)", unit: "completed")
                    }
                    .padding(.horizontal)
                    if let debrief = store.debriefs[race.id] {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "AI Coach Debrief").padding(.horizontal)
                            AIDebriefCard(debrief: debrief).padding(.horizontal)
                        }
                    }
                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatsView: View {
    @EnvironmentObject var store: RaceStore
    var body: some View {
        ZStack {
            Color.navyBg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("MY STATS")
                        .font(.system(size: 30, weight: .black)).foregroundColor(.white)
                        .padding(.horizontal)
                    let pb = store.personalBests
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        StatTile(label: "Total Races", value: "\(pb.totalRaces)", unit: "")
                        StatTile(label: "Best Speed", value: String(format: "%.1f", pb.fastestSpeed), unit: "knots", valueColor: .greenAccent)
                        StatTile(label: "Most Tacks", value: "\(pb.mostTacks)", unit: "in one race")
                        StatTile(label: "Best Lap", value: pb.bestLapTime > 0 ? pb.bestLapTime.raceFormatted : "—", unit: "mm:ss", valueColor: .accentCyan)
                    }
                    .padding(.horizontal)
                    if !store.races.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Speed Over Time").padding(.horizontal)
                            CardContainer {
                                SpeedBarChart(races: store.races).padding(16)
                            }
                            .padding(.horizontal)
                        }
                    }
                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
        }
    }
}

struct SpeedBarChart: View {
    let races: [Race]
    var body: some View {
        let maxSpeed = races.map(\.maxSpeed).max() ?? 1
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(races.prefix(12)) { race in
                RoundedRectangle(cornerRadius: 3)
                    .fill(race.id == races.first?.id ? Color.accentCyan : Color.surfaceAlt)
                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.borderColor, lineWidth: 1))
                    .frame(height: CGFloat(race.maxSpeed / maxSpeed) * 80)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 90)
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.navyBg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SETTINGS")
                            .font(.system(size: 30, weight: .black)).foregroundColor(.white)
                            .padding(.horizontal)
                        VStack(spacing: 10) {
                            ForEach([
                                ("👤", "Profile", "Alex · Solo sailor"),
                                ("⌚", "Apple Watch", "Pair your watch"),
                                ("⛵", "Boat Classes", "Manage your boats"),
                                ("📊", "Units", "Knots, Degrees"),
                                ("🔔", "Notifications", "Race reminders"),
                                ("📡", "Connectivity", "Auto-detect"),
                            ], id: \.0) { icon, title, sub in
                                CardContainer {
                                    HStack {
                                        Text(icon).font(.system(size: 20))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(title).font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                                            Text(sub).font(.system(size: 12)).foregroundColor(.mutedText)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(.mutedText)
                                    }
                                    .padding(14)
                                }
                            }
                        }
                        .padding(.horizontal)
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16)
                }
            }
        }
    }
}
