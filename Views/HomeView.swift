import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: RaceStore
    @State private var showSetup = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.navyBg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DINGHY\nRACE TRACKER")
                                    .font(.system(size: 30, weight: .black))
                                    .foregroundColor(.white)
                                Text("Good sailing, Alex")
                                    .font(.system(size: 13))
                                    .foregroundColor(.mutedText)
                            }
                            Spacer()
                            Text("⛵").font(.system(size: 36))
                                .padding(10)
                                .background(Color.surfaceAlt)
                                .clipShape(Circle())
                        }
                        .padding(.horizontal)
                        PrimaryButton(title: "▶ Start New Race") { showSetup = true }
                            .padding(.horizontal)
                        if let last = store.races.first {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "Last Race").padding(.horizontal)
                                LastRaceCard(race: last).padding(.horizontal)
                            }
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Personal Bests").padding(.horizontal)
                            CardContainer {
                                let pb = store.personalBests
                                BestRow(icon: "🏆", label: "Fastest Speed", value: String(format: "%.1f kts", pb.fastestSpeed))
                                Divider().background(Color.borderColor)
                                BestRow(icon: "⚡", label: "Best Lap", value: pb.bestLapTime > 0 ? pb.bestLapTime.raceFormatted : "—")
                                Divider().background(Color.borderColor)
                                BestRow(icon: "🎯", label: "Total Races", value: "\(pb.totalRaces)")
                            }
                            .padding(.horizontal)
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .sheet(isPresented: $showSetup) { RaceSetupView() }
    }
}

struct LastRaceCard: View {
    let race: Race
    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(race.name).font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                        Text("\(race.date.formatted(date: .abbreviated, time: .omitted)) · \(race.boat.boatClass.rawValue) · \(race.laps.count) laps")
                            .font(.system(size: 12)).foregroundColor(.mutedText)
                    }
                    Spacer()
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    StatTile(label: "Max Speed", value: String(format: "%.1f", race.maxSpeed), unit: "knots", valueColor: .accentCyan)
                    StatTile(label: "Race Time", value: race.duration?.raceFormatted ?? "—", unit: "mm:ss")
                    StatTile(label: "Tacks", value: "\(race.tackCount)", unit: "manoeuvres", valueColor: .greenAccent)
                    StatTile(label: "Jibes", value: "\(race.jibeCount)", unit: "manoeuvres", valueColor: .orangeAccent)
                }
            }
            .padding(14)
        }
    }
}

struct BestRow: View {
    let icon: String; let label: String; let value: String
    var body: some View {
        HStack {
            Text(icon).font(.system(size: 18))
            Text(label).font(.system(size: 14, weight: .medium)).foregroundColor(.white)
            Spacer()
            Text(value).font(.system(size: 20, weight: .black, design: .rounded)).foregroundColor(.accentCyan)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}
