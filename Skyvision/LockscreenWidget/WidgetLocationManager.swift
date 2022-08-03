//
//  WidgetLocationManager.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 18.07.2022.
//

import Foundation
import CoreLocation

class WidgetLocationManager: NSObject, CLLocationManagerDelegate {
    // MARK: - Private properties
    private var locationManager: CLLocationManager?
    private var geoCoder: CLGeocoder?
    private var onUserLocation: ((CLPlacemark?) -> Void)?
    
    // MARK: - Initialisation
    init(locationManager: CLLocationManager = CLLocationManager(), geoCoder: CLGeocoder = CLGeocoder()) {
        super.init()
        self.locationManager = locationManager
        self.geoCoder = geoCoder
        self.locationManager?.delegate = self
    }
    
    // MARK: - Public API
    func requestLocation(completion: @escaping ((CLPlacemark?) -> Void)) {
        if self.locationManager?.authorizationStatus == .authorizedWhenInUse || self.locationManager?.authorizationStatus == .authorizedAlways {
            onUserLocation = completion
            locationManager?.requestLocation()
        }
    }
    
    // MARK: - Private API
    private func findPlacemark(for location: CLLocation?) async -> CLPlacemark? {
        guard let geoCoder, let location else { return nil }
        do {
            let result = try await geoCoder.reverseGeocodeLocation(location)
            guard let placemark = result.first else { return nil }
            return placemark
        } catch {
            print("[WidgetLocationManager] Error getting placemark for user's location: \(error)")
            return nil
        }
    }
    
}
// MARK: - CLLocationManagerDelegate
extension WidgetLocationManager {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task {
            let placemark = await findPlacemark(for: location)
            onUserLocation?(placemark)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[WidgetLocationManager] failed with error: \(error.localizedDescription)")
    }
}
