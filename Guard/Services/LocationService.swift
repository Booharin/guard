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

protocol LocationServiceInterface {}

final class LocationSerice: NSObject, LocationServiceInterface, CLLocationManagerDelegate {
	
	private var locationManager: CLLocationManager
	override init() {
		self.locationManager = CLLocationManager()
		super.init()
		self.configureLocationManager()
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
}
