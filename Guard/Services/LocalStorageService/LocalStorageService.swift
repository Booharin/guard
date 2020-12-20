//
//  LocalStorageService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 06.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation

protocol HasLocalStorageService {
	var localStorageService: LocalStorageServiceInterface { get set }
}

/// Core data model handle service interface
protocol LocalStorageServiceInterface {
	
	/// Method for saving user profile to CoreData
	/// - Parameters:
	///   - profile: User profile
	func saveProfile(_ profile: UserProfile)

	/// Method for geting user profile from CoreData by mail
	///  - Parameters:
	///   - email: user email
	/// - Returns: user profile
	func getProfile(by email: String) -> UserProfile?

	//TODO: - Temporary solution
	func getCurrenClientProfile() -> UserProfile?
	/// Method for saving cities to storage
	///  - Parameters:
	///   - cities: cities array
	func saveCities(_ cities: [CityModel])
	/// Method for geting russian cities from storage
	/// - Returns: cities array
	func getRussianCities() -> [CityModel]
}
/// Core data model handle service
final class LocalStorageService: LocalStorageServiceInterface {
	private let coreDataManager = CoreDataManager(withDataModelName: "GuardDataModel", bundle: .main)

	func saveProfile(_ profile: UserProfile) {
		// remove all profiles before saving
		let profiles = coreDataManager.fetchObjects(entity: UserProfileObject.self,
													context: coreDataManager.mainContext)
		coreDataManager.delete(profiles)

		let _ = UserProfileObject(userProfile: profile,
								  context: coreDataManager.mainContext)
		coreDataManager.saveContext(synchronously: true)
	}

	func getProfile(by email: String) -> UserProfile? {
		let profiles = coreDataManager.fetchObjects(entity: UserProfileObject.self,
													predicate: NSPredicate(format: "email = %@", email),
													context: coreDataManager.mainContext)
		guard let profileObject = profiles.first else { return nil }
		return UserProfile(userProfileObject: profileObject)
	}

	func getCurrenClientProfile() -> UserProfile? {
		let profiles = coreDataManager.fetchObjects(entity: UserProfileObject.self,
													context: coreDataManager.mainContext)
		guard let profileObject = profiles.first else { return nil }
		return UserProfile(userProfileObject: profileObject)
	}

	func saveCities(_ cities: [CityModel]) {
		let cityObjects = coreDataManager.fetchObjects(entity: CityObject.self,
													   context: coreDataManager.mainContext)
		coreDataManager.delete(cityObjects)

		let _ = cities.map {
			CityObject(cityModel: $0,
					   context: coreDataManager.mainContext)
		}
		coreDataManager.saveContext(synchronously: true)
	}

	func getRussianCities() -> [CityModel] {
		let cityObjects = coreDataManager.fetchObjects(entity: CityObject.self,
													   context: coreDataManager.mainContext)
		return cityObjects
			.filter { $0.countryCode == 7 }
			.map { CityModel(cityObject: $0) }
	}
}
