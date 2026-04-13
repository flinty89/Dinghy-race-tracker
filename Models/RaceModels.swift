import Foundation
import CoreLocation

// MARK: - Boat

struct Boat: Codable, Identifiable {
    let id: UUID
    var name: String
    var boatClass: BoatClass
    var handicap: Int?

    init(id: UUID = UUID(), name: String, boatClass: BoatClass, handicap: Int? = nil) {
        self.id = id
        self.name = name
        self.boatClass = boatClass
        self.handicap = handicap
    }
}

enum BoatClass: String, Codable, CaseIterable {
    case solo = "Solo"
    case ilca7 = "ILCA 7"
    case ilca6 = "ILCA 6"
    case rsAero = "RS Aero"
    case finn = "Finn"
    case other = "Other"
}

// MARK: - Race

struct Race: Codable, Identifiable {
    let id: UUID
    var name: String
    var date: Date
    var boat: Boat
    var courseType: CourseType
    var plannedLaps: Int
    var status: RaceStatus
    var trackPoints: [TrackPoint]
    var laps: [Lap]
    var manoeuvres: [Manoeuvre]
    var finishTime: Date?

    var duration: TimeInterval? {
        guard let finish = finishTime else { return nil }
        return finish.timeIntervalSince(date)
    }

    var maxSpeed: Double { trackPoints.map(\.speedKnots).max() ?? 0 }
    var avgSpeed: Double {
        guard !trackPoints.isEmpty else { return 0 }
        return trackPoints.map(\.speedKnots).reduce(0, +) / Double(trackPoints.count)
    }
    var tackCount: Int { manoeuvres.filter { $0.type == .tack }.count }
    var jibeCount: Int { manoeuvres.filter { $0.type == .jibe }.count }

    init(id: UUID = UUID(), name: String, date: Date = Date(), boat: Boat,
         courseType: CourseType = .olympicTriangle, plannedLaps: Int = 3) {
        self.id = id; self.name = name; self.date = date; self.boat = boat
        self.courseType = courseType; self.plannedLaps = plannedLaps
        self.status = .notStarted; self.trackPoints = []; self.laps = []; self.manoeuvres = []
    }
}

enum RaceStatus: String, Codable { case notStarted, active, finished, synced }

enum CourseType: String, Codable, CaseIterable {
    case olympicTriangle = "Olympic Triangle"
    case windwardLeeward = "Windward / Leeward"
    case clubPursuit = "Club Pursuit"
    case trapezoid = "Trapezoid"
}

// MARK: - Track Point

struct TrackPoint: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let speedKnots: Double
    let headingDegrees: Double
    let windDirectionDegrees: Double?

    init(id: UUID = UUID(), timestamp: Date = Date(), coordinate: CLLocationCoordinate2D,
         speedKnots: Double, headingDegrees: Double, windDirectionDegrees: Double? = nil) {
        self.id = id; self.timestamp = timestamp
        self.latitude = coordinate.latitude; self.longitude = coordinate.longitude
        self.speedKnots = speedKnots; self.headingDegrees = headingDegrees
        self.windDirectionDegrees = windDirectionDegrees
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Lap

struct Lap: Codable, Identifiable {
    let id: UUID
    let number: Int
    let startTime: Date
    var endTime: Date?

    var duration: TimeInterval? {
        guard let end = endTime else { return nil }
        return end.timeIntervalSince(startTime)
    }

    init(id: UUID = UUID(), number: Int, startTime: Date = Date()) {
        self.id = id; self.number = number; self.startTime = startTime
    }
}

// MARK: - Manoeuvre

struct Manoeuvre: Codable, Identifiable {
    let id: UUID
    let type: ManoeuvreType
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let speedAtManoeuvre: Double

    init(id: UUID = UUID(), type: ManoeuvreType, timestamp: Date = Date(),
         coordinate: CLLocationCoordinate2D, speedAtManoeuvre: Double) {
        self.id = id; self.type = type; self.timestamp = timestamp
        self.latitude = coordinate.latitude; self.longitude = coordinate.longitude
        self.speedAtManoeuvre = speedAtManoeuvre
    }
}

enum ManoeuvreType: String, Codable { case tack = "Tack"; case jibe = "Jibe" }

enum ConnectivityMode: String, Codable {
    case autoDetect = "Auto-detect"
    case offlineSync = "Offline — sync after race"
    case liveStream = "Live streaming (cellular)"
}
