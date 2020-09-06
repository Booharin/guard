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
	///   - email: User email
	/// - Returns: User profile
	func getProfile(by email: String) -> UserProfile?

	/// Method for geting user profile from CoreData
	/// - Returns: User profile
	func getProfile() -> UserProfile?
}
/// Core data model handle service
final class LocalStorageService: LocalStorageServiceInterface {
	private let coreDataManager = CoreDataManager(withDataModelName: "GuardDataModel", bundle: .main)

	func saveProfile(_ profile: UserProfile) {

		deleteAllProfilesIfTheyMoreThanOne()
		
		let profileObject = UserProfileObject(context: coreDataManager.mainContext)
		profileObject.email = profile.email
		profileObject.userType = profile.userType
		profileObject.firstName = profile.firstName
		profileObject.lastName = profile.lastName
		profileObject.city = profile.city

		coreDataManager.saveContext(synchronously: true)
	}

	func getProfile(by email: String) -> UserProfile? {
		let profiles = coreDataManager.fetchObjects(entity: UserProfileObject.self,
													predicate: NSPredicate(format: "email = %@", email),
													context: coreDataManager.mainContext)
		guard let profileObject = profiles.first else { return nil }
		return UserProfile(userProfileObject: profileObject)
	}
	
	func getProfile() -> UserProfile? {
		let profiles = coreDataManager.fetchObjects(entity: UserProfileObject.self,
													context: coreDataManager.mainContext)
		guard let profileObject = profiles.first else { return nil }
		return UserProfile(userProfileObject: profileObject)
	}
	
	private func deleteAllProfilesIfTheyMoreThanOne() {
		let profiles = coreDataManager.fetchObjects(entity: UserProfileObject.self,
													context: coreDataManager.mainContext)
		if profiles.count > 1 {
			coreDataManager.delete(profiles)
			coreDataManager.saveContext(synchronously: true)
		}
	}
}
