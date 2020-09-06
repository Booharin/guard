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
	/// Method for geting user profile from CoreData
	/// - Returns: User profile
	func getProfile() -> UserProfile?
}
/// Core data model handle service
final class LocalStorageService: LocalStorageServiceInterface {
	private let coreDataManager = CoreDataManager(withDataModelName: "GuardDataModel", bundle: .main)

	func saveProfile(_ profile: UserProfile) {
		
	}

	func getProfile() -> UserProfile? {
		return UserProfile(userType: .client)
	}
}
