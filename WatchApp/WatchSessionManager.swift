import Foundation
import CoreLocation
import WatchConnectivity

class WatchSessionManager: NSObject, ObservableObject {
    @Published var isTracking = false
    @Published var currentSpeed: Double = 0
    @Published var currentHeading: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var trackPoints: [WatchTrackPoint] = []

    private let locationManager = CLLocationManager()
    private var timer: Timer?
    private var startTime: Date?
    private let metersPerSecToKnots = 1.94384

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 2
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func startTracking() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        startTime = Date()
        isTracking = true
        trackPoints = []
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedTime = Date().timeIntervalSince(self.startTime ?? Date())
        }
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        timer?.invalidate()
        isTracking = false
        sendDataToPhone()
    }

    private func sendDataToPhone() {
        guard WCSession.default.isReachable else { saveLocally(); return }
        let payload: [String: Any] = [
            "trackPoints": trackPoints.map { $0.toDictionary() },
            "duration": elapsedTime,
            "startTime": startTime?.timeIntervalSince1970 ?? 0
        ]
        WCSession.default.sendMessage(payload, replyHandler: nil)
    }

    private func saveLocally() {
        if let data = try? JSONEncoder().encode(trackPoints) {
            UserDefaults.standard.set(data, forKey: "pending_track_points")
            UserDefaults.standard.set(elapsedTime, forKey: "pending_duration")
        }
    }
}

extension WatchSessionManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last, isTracking else { return }
        let speed = max(0, loc.speed) * metersPerSecToKnots
        currentSpeed = speed
        let point = WatchTrackPoint(
            timestamp: Date(),
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude,
            speedKnots: speed,
            headingDegrees: currentHeading
        )
        trackPoints.append(point)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        currentHeading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    }
}

extension WatchSessionManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
}

struct WatchTrackPoint: Codable {
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let speedKnots: Double
    let headingDegrees: Double

    func toDictionary() -> [String: Any] {
        ["timestamp": timestamp.timeIntervalSince1970,
         "lat": latitude, "lng": longitude,
         "speed": speedKnots, "heading": headingDegrees]
    }
}
