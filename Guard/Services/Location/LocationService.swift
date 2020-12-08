//
//  LocationService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 16.07.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import CoreLocation

protocol HasLocationService {
    var locationService: LocationServiceInterface { get set }
}

protocol LocationServiceInterface {
	func geocode(completion: @escaping (_ city: String?) -> Void)
}

final class LocationSerice: NSObject, LocationServiceInterface, CLLocationManagerDelegate {
	
	private var locationManager: CLLocationManager
	override init() {
		self.locationManager = CLLocationManager()
//		super.init()
//		self.configureLocationManager()
	}
	
	private func configureLocationManager() {
		self.locationManager.requestWhenInUseAuthorization()
		
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
			locationManager.startUpdatingLocation()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
		#if DEBUG
		print("locations = \(locValue.latitude) \(locValue.longitude)")
		#endif
	}
	
	func geocode(completion: @escaping (_ city: String?) -> Void)  {
		guard
			let latitude = locationManager.location?.coordinate.latitude,
			let longitude = locationManager.location?.coordinate.longitude else { return }
		// change language for ru_RU placemark names
		guard let currentLanguage = UserDefaults.standard.value(forKey: "AppleLanguages") as? [String] else { return }
		UserDefaults.standard.set(["ru_RU"], forKey: "AppleLanguages")
		CLGeocoder()
			.reverseGeocodeLocation(
				CLLocation(latitude: latitude,
						   longitude: longitude)
			) { [weak self] placemark, error in
				// put current language back
				UserDefaults.standard.set(currentLanguage, forKey: "AppleLanguages")
				
				guard let placemark = placemark, error == nil else {
					completion(nil)
					return
				}
				
				self?.locationManager.stopUpdatingLocation()
				completion(placemark.first?.locality)
		}
	}
}
