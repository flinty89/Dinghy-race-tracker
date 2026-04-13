import SwiftUI
import CoreLocation

struct RaceSetupView: View {
    @EnvironmentObject var store: RaceStore
    @EnvironmentObject var gps: GPSService
    @Environment(\.dismiss) var dismiss
    @State private var boatClass: BoatClass = .solo
    @State private var courseType: CourseType = .olympicTriangle
    @State private var laps = 3
    @State private var raceName = ""
    @State private var goRacing = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.navyBg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("RACE SETUP")
                            .font(.system(size: 30, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        VStack(spacing: 14) {
                            FormField(label: "Race Name") {
                                TextField("e.g. Sunday Race #1", text: $raceName)
                                    .textFieldStyle(DinghyTextFieldStyle())
                            }
                            FormField(label: "Boat Class") {
                                Picker("", selection: $boatClass) {
                                    ForEach(BoatClass.allCases, id: \.self) {
                                        Text($0.rawValue).tag($0)
                                    }
                                }
                                .pickerStyle(.menu)
                                .dinghyPickerStyle()
                            }
                            FormField(label: "Number of Laps") {
                                Picker("", selection: $laps) {
                                    ForEach([2,3,4,5], id: \.self) {
                                        Text("\($0) laps").tag($0)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        .padding(.horizontal)
                        GPSStatusCard(gps: gps).padding(.horizontal)
                        PrimaryButton(title: "▶ Begin Race") {
                            let boat = Boat(name: boatClass.rawValue, boatClass: boatClass)
                            let name = raceName.isEmpty ? "Race \(store.races.count + 1)" : raceName
                            let race = Race(name: name, boat: boat, courseType: courseType, plannedLaps: laps)
                            store.save(race)
                            goRacing = true
                        }
                        .padding(.horizontal)
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationDestination(isPresented: $goRacing) {
                if let race = store.races.first { ActiveRaceView(race: race) }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct ActiveRaceView: View {
    @EnvironmentObject var store: RaceStore
    @EnvironmentObject var gps: GPSService
    var race: Race
    @State private var currentRace: Race
    @State private var elapsed: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showFinish = false

    init(race: Race) {
        self.race = race
        _currentRace = State(initialValue: race)
    }

    var body: some View {
        ZStack {
            Color.navyBg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    LiveBadge()
                    Spacer()
                    Text(elapsed.raceFormatted)
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                    Text(currentRace.boat.boatClass.rawValue.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color.accentCyan.opacity(0.15))
                        .foregroundColor(.accentCyan)
                        .cornerRadius(20)
                }
                .padding()
                VStack(spacing: 2) {
                    Text(String(format: "%.1f", gps.currentSpeed))
                        .font(.system(size: 90, weight: .black, design: .rounded))
                        .foregroundColor(.accentCyan)
                        .monospacedDigit()
                    Text("KNOTS")
                        .font(.system(size: 16, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.mutedText)
                }
                .padding(.vertical, 8)
                ScrollView {
                    VStack(spacing: 14) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            StatTile(label: "Avg Speed", value: String(format: "%.1f", currentRace.avgSpeed), unit: "knots", valueColor: .accentCyan)
                            StatTile(label: "Max Speed", value: String(format: "%.1f", currentRace.maxSpeed), unit: "knots", valueColor: .greenAccent)
                            StatTile(label: "Heading", value: String(format: "%.0f°", gps.currentHeading), unit: "degrees")
                            StatTile(label: "Lap", value: "\(currentRace.laps.count + 1) / \(currentRace.plannedLaps)", unit: "current")
                        }
                        .padding(.horizontal)
                        PrimaryButton(title: "■ Finish Race", color: .redAccent) { finishRace() }
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear { startRace() }
        .onDisappear { stopRace() }
        .navigationDestination(isPresented: $showFinish) {
            RaceReviewView(race: currentRace)
        }
    }

    private func startRace() {
        gps.startTracking()
        currentRace.status = .active
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsed += 1
            if let point = gps.currentTrackPoint() {
                currentRace.trackPoints.append(point)
            }
            store.save(currentRace)
        }
    }

    private func stopRace() { timer?.invalidate(); gps.stopTracking() }

    private func finishRace() {
        timer?.invalidate()
        gps.stopTracking()
        currentRace.finishTime = Date()
        currentRace.status = .finished
        store.save(currentRace)
        showFinish = true
    }
}

struct RaceReviewView: View {
    @EnvironmentObject var store: RaceStore
    let race: Race
    @State private var debrief: AIDebrief?
    @State private var loadingDebrief = false
    @Environment(\.dismiss) var dismiss
    private let aiCoach = AICoachService()

    var body: some View {
        ZStack {
            Color.navyBg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("RACE\nCOMPLETE")
                                .font(.system(size: 30, weight: .black))
                                .foregroundColor(.white)
                            Text(race.name)
                                .font(.system(size: 13))
                                .foregroundColor(.mutedText)
                        }
                        Spacer()
                        Text("✓ Saved")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.greenAccent.opacity(0.15))
                            .foregroundColor(.greenAccent)
                            .cornerRadius(20)
                    }
                    .padding(.horizontal)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        StatTile(label: "Race Time", value: race.duration?.raceFormatted ?? "—", unit: "mm:ss")
                        StatTile(label: "Max Speed", value: String(format: "%.1f", race.maxSpeed), unit: "knots", valueColor: .accentCyan)
                        StatTile(label: "Tacks", value: "\(race.tackCount)", unit: "manoeuvres", valueColor: .greenAccent)
                        StatTile(label: "Jibes", value: "\(race.jibeCount)", unit: "manoeuvres", valueColor: .orangeAccent)
                    }
                    .padding(.horizontal)
                    if !race.laps.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Lap Times").padding(.horizontal)
                            CardContainer {
                                let best = race.laps.compactMap(\.duration).min()
                                ForEach(race.laps) { lap in
                                    LapRow(lap: lap, isBest: lap.duration == best)
                                    if lap.id != race.laps.last?.id {
                                        Divider().background(Color.borderColor)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "AI Coach Debrief").padding(.horizontal)
                        if loadingDebrief {
                            CardContainer {
                                HStack(spacing: 12) {
                                    ProgressView().tint(.accentCyan)
                                    Text("Analysing your race...")
                                        .font(.system(size: 14)).foregroundColor(.mutedText)
                                }
                                .padding()
                            }
                            .padding(.horizontal)
                        } else if let d = debrief {
                            AIDebriefCard(debrief: d).padding(.horizontal)
                        } else {
                            PrimaryButton(title: "🧠 Generate AI Debrief") { generateDebrief() }
                                .padding(.horizontal)
                        }
                    }
                    VStack(spacing: 10) {
                        PrimaryButton(title: "▶ Race Again") { dismiss() }
                        Button("Back to Home") { dismiss() }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.mutedText)
                    }
                    .padding(.horizontal)
                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear { if let saved = store.debriefs[race.id] { debrief = saved } }
    }

    private func generateDebrief() {
        loadingDebrief = true
        Task {
            let result = try? await aiCoach.generateDebrief(for: race)
            await MainActor.run {
                debrief = result
                if let d = result { store.saveDebrief(d) }
                loadingDebrief = false
            }
        }
    }
}

struct LapRow: View {
    let lap: Lap; let isBest: Bool
    var body: some View {
        HStack {
            Text("LAP \(lap.number)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.mutedText)
            Spacer()
            Text(lap.duration?.raceFormatted ?? "—")
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(isBest ? .greenAccent : .white)
            if isBest { Text("⚡").font(.system(size: 14)) }
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
    }
}

struct AIDebriefCard: View {
    let debrief: AIDebrief
    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 14) {
                Text(debrief.summary)
                    .font(.system(size: 14)).foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.top, 14)
                Divider().background(Color.borderColor)
                ForEach(debrief.insights) { insight in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(insight.sentiment == .positive ? Color.greenAccent : insight.sentiment == .negative ? Color.redAccent : Color.accentCyan)
                            .frame(width: 8, height: 8).padding(.top, 5)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(insight.title)
                                .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                            Text(insight.detail)
                                .font(.system(size: 12)).foregroundColor(.mutedText)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                if !debrief.recommendations.isEmpty {
                    Divider().background(Color.borderColor)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RECOMMENDATIONS")
                            .font(.system(size: 10, weight: .bold)).tracking(1.2)
                            .foregroundColor(.mutedText)
                        ForEach(debrief.recommendations, id: \.self) { rec in
                            HStack(alignment: .top, spacing: 8) {
                                Text("→").foregroundColor(.accentCyan)
                                Text(rec).font(.system(size: 13)).foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 16).padding(.bottom, 14)
                }
            }
        }
    }
}

struct GPSStatusCard: View {
    @ObservedObject var gps: GPSService
    var body: some View {
        CardContainer {
            HStack(spacing: 12) {
                Text("📡").font(.system(size: 24))
                VStack(alignment: .leading, spacing: 4) {
                    Text("GPS Status")
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                    Text(gps.authStatus == .authorizedWhenInUse ? "Signal acquired" : "Waiting for permission")
                        .font(.system(size: 12)).foregroundColor(.mutedText)
                }
                Spacer()
                Text(gps.authStatus == .authorizedWhenInUse ? "READY" : "PENDING")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(gps.authStatus == .authorizedWhenInUse ? Color.greenAccent.opacity(0.15) : Color.orangeAccent.opacity(0.15))
                    .foregroundColor(gps.authStatus == .authorizedWhenInUse ? .greenAccent : .orangeAccent)
                    .cornerRadius(20)
            }
            .padding(14)
        }
    }
}

struct FormField<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold)).tracking(1.2)
                .foregroundColor(.mutedText)
            content
        }
    }
}

struct DinghyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration.padding(12).background(Color.surfaceAlt).foregroundColor(.white)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderColor, lineWidth: 1))
            .cornerRadius(12)
    }
}

extension View {
    func dinghyPickerStyle() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading).padding(12)
            .background(Color.surfaceAlt)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderColor, lineWidth: 1))
            .cornerRadius(12)
    }
}
