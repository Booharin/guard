//
//  LocalStorageService.swift
//  Guard
//
//  Created by Alexandr Bukharin on 06.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation
import UIKit.UIImage

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

	/// Method for saving reviews to storage
	///  - Parameters:
	///   - reviews: reviews
	func saveReviews(_ reviews: [UserReview])

	/// Method for geting reviews from storage
	/// - Returns: reviews array
	func getReviews() -> [UserReview]

	/// Method for saving profile image to FileManager
	///  - Parameters:
	///   - data: image in Data format
	///   - name: Name in directory
	func saveImage(data: Data,
				   name: String)

	/// Method for geting profile image from FileManager
	///  - Parameters:
	///   - name: Name in directory
	/// - Returns: Image
	func getImage(with name: String) -> UIImage?

	/// Method for saving settings
	///  - Parameters:
	///   - settings: settings model
	func saveSettings(_ settings: SettingsModel)

	/// Method for getting settings
	///  - Parameters:
	///   - id: profile id
	/// - Returns: settings model
	func getSettings(for id: Int) -> SettingsModel?
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
													predicate: NSPredicate(format: "email == %@", email),
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

	func saveReviews(_ reviews: [UserReview]) {
		let reviewsObjects = coreDataManager.fetchObjects(entity: ReviewObject.self,
														  context: coreDataManager.mainContext)
		coreDataManager.delete(reviewsObjects)
		
		let _ = reviews.map {
			ReviewObject(reviewModel: $0,
						 context: coreDataManager.mainContext)
		}
		coreDataManager.saveContext(synchronously: true)
	}

	func getReviews() -> [UserReview] {
		let reviewObjects = coreDataManager.fetchObjects(entity: ReviewObject.self,
														 context: coreDataManager.mainContext)
		return reviewObjects.map { UserReview(reviewObject: $0) }
	}
	
	func saveImage(data: Data,
				   name: String) {
		let filename = getDocumentsDirectory().appendingPathComponent(name)
		try? data.write(to: filename)
	}

	func getImage(with name: String) -> UIImage? {
		let imageURL = getDocumentsDirectory().appendingPathComponent(name)
		return UIImage(contentsOfFile: imageURL.path)
	}

	private func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}

	func saveSettings(_ settings: SettingsModel) {
		let settingsObjects = coreDataManager.fetchObjects(entity: SettingsObject.self,
														   context: coreDataManager.mainContext)
		coreDataManager.delete(settingsObjects)
		
		let _ = SettingsObject(settingsModel: settings,
							   context: coreDataManager.mainContext)
		coreDataManager.saveContext(synchronously: true)
	}

	func getSettings(for id: Int) -> SettingsModel? {
		let settingsObjects = coreDataManager.fetchObjects(entity: SettingsObject.self,
														   predicate: NSPredicate(format: "id == %d", id),
														   context: coreDataManager.mainContext)
		guard let settingObject = settingsObjects.first else { return nil }
		return SettingsModel(settingsObject: settingObject)
	}
}
