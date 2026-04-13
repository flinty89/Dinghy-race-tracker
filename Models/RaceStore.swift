import Foundation

class RaceStore: ObservableObject {
    @Published var races: [Race] = []
    @Published var debriefs: [UUID: AIDebrief] = [:]

    private let saveKey = "saved_races"
    private let debriefKey = "saved_debriefs"

    init() { load() }

    func save(_ race: Race) {
        if let index = races.firstIndex(where: { $0.id == race.id }) {
            races[index] = race
        } else {
            races.insert(race, at: 0)
        }
        persist()
    }

    func delete(_ race: Race) {
        races.removeAll { $0.id == race.id }
        debriefs.removeValue(forKey: race.id)
        persist()
    }

    func saveDebrief(_ debrief: AIDebrief) {
        debriefs[debrief.raceId] = debrief
        persistDebriefs()
    }

    var personalBests: PersonalBests {
        PersonalBests(
            fastestSpeed: races.map(\.maxSpeed).max() ?? 0,
            bestLapTime: races.flatMap(\.laps).compactMap(\.duration).min() ?? 0,
            mostTacks: races.map(\.tackCount).max() ?? 0,
            totalRaces: races.count
        )
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(races) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func persistDebriefs() {
        if let data = try? JSONEncoder().encode(debriefs) {
            UserDefaults.standard.set(data, forKey: debriefKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Race].self, from: data) {
            races = decoded
        }
        if let data = UserDefaults.standard.data(forKey: debriefKey),
           let decoded = try? JSONDecoder().decode([UUID: AIDebrief].self, from: data) {
            debriefs = decoded
        }
    }
}

struct AIDebrief: Codable, Identifiable {
    let id: UUID
    let raceId: UUID
    let generatedAt: Date
    var summary: String
    var insights: [Insight]
    var recommendations: [String]

    struct Insight: Codable, Identifiable {
        let id: UUID
        let category: InsightCategory
        let title: String
        let detail: String
        let sentiment: Sentiment

        init(id: UUID = UUID(), category: InsightCategory,
             title: String, detail: String, sentiment: Sentiment) {
            self.id = id; self.category = category
            self.title = title; self.detail = detail; self.sentiment = sentiment
        }
    }

    enum InsightCategory: String, Codable {
        case speed, manoeuvres, tactics, consistency, lapTime
    }

    enum Sentiment: String, Codable { case positive, neutral, negative }

    init(id: UUID = UUID(), raceId: UUID, generatedAt: Date = Date(),
         summary: String, insights: [Insight], recommendations: [String]) {
        self.id = id; self.raceId = raceId; self.generatedAt = generatedAt
        self.summary = summary; self.insights = insights; self.recommendations = recommendations
    }
}

struct PersonalBests {
    let fastestSpeed: Double
    let bestLapTime: TimeInterval
    let mostTacks: Int
    let totalRaces: Int
}
