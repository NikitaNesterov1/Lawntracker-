import CoreLocation
import Combine
import Foundation

final class LocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var authorizationDescription = "Not requested"
    @Published private(set) var lastLocation: CLLocation?
    @Published private(set) var lastResolvedName: String?
    @Published private(set) var isLocating = false
    @Published var errorMessage: String?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        updateAuthorizationDescription(manager.authorizationStatus)
    }

    func requestUserLocation() {
        errorMessage = nil
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            requestCurrentLocation()
        case .denied, .restricted:
            errorMessage = "Location permission is off. You can still search by city or ZIP."
        @unknown default:
            errorMessage = "Location permission is unavailable."
        }
        updateAuthorizationDescription(manager.authorizationStatus)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.updateAuthorizationDescription(manager.authorizationStatus)
            if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
                self.requestCurrentLocation()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.isLocating = false
            self.lastLocation = location
            self.resolveName(for: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLocating = false
            self.errorMessage = error.localizedDescription
        }
    }

    private func requestCurrentLocation() {
        isLocating = true
        manager.requestLocation()
    }

    private func resolveName(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            let placemark = placemarks?.first
            let locality = placemark?.locality
            let admin = placemark?.administrativeArea
            let postalCode = placemark?.postalCode

            let name = [locality, admin, postalCode]
                .compactMap { value in
                    guard let value = value, !value.isEmpty else { return nil }
                    return value
                }
                .joined(separator: ", ")

            DispatchQueue.main.async {
                self.lastResolvedName = name.isEmpty ? nil : name
            }
        }
    }

    private func updateAuthorizationDescription(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            authorizationDescription = "Not requested"
        case .restricted:
            authorizationDescription = "Restricted"
        case .denied:
            authorizationDescription = "Denied"
        case .authorizedAlways, .authorizedWhenInUse:
            authorizationDescription = "Allowed"
        @unknown default:
            authorizationDescription = "Unknown"
        }
    }
}
