import Foundation
import CoreLocation
import Combine

class GPSService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentSpeed: Double = 0
    @Published var currentHeading: Double = 0
    @Published var currentCoordinate: CLLocationCoordinate2D?
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    @Published var isTracking = false

    private let manager = CLLocationManager()
    private let metersPerSecondToKnots = 1.94384

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = 2
        manager.headingFilter = 3
    }

    func requestPermission() { manager.requestWhenInUseAuthorization() }

    func startTracking() {
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
        isTracking = true
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
        isTracking = false
    }

    func currentTrackPoint() -> TrackPoint? {
        guard let coord = currentCoordinate else { return nil }
        return TrackPoint(coordinate: coord, speedKnots: currentSpeed, headingDegrees: currentHeading)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentCoordinate = location.coordinate
        let rawSpeed = location.speed >= 0 ? location.speed : 0
        currentSpeed = rawSpeed * metersPerSecondToKnots
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        currentHeading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authStatus = status
    }
}
