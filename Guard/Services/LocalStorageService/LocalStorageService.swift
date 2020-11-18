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
}
/// Core data model handle service
final class LocalStorageService: LocalStorageServiceInterface {
	private let coreDataManager = CoreDataManager(withDataModelName: "GuardDataModel", bundle: .main)

	func saveProfile(_ profile: UserProfile) {
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
}
