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
	func saveProfile<T>(_ profile: T)
	
	/// Method for geting lawyer profile from CoreData by mail
	///  - Parameters:
	///   - email: lawyer email
	/// - Returns: lawyer profile
	func getLawyerProfile(by email: String) -> LawyerProfile?
	
	/// Method for geting client profile from CoreData by mail
	///  - Parameters:
	///   - email: client email
	/// - Returns: client profile
	func getClientProfile(by email: String) -> ClientProfile?
	//TODO: - Temporary solution
	func getCurrenClientProfile() -> ClientProfile?
}
/// Core data model handle service
final class LocalStorageService: LocalStorageServiceInterface {
	private let coreDataManager = CoreDataManager(withDataModelName: "GuardDataModel", bundle: .main)
	
	func saveProfile<T>(_ profile: T) {
		
		switch profile {
		case (let x) where x is ClientProfile:
			guard let clientProfile = profile as? ClientProfile else { return }
			_ = ClientProfileObject(clientProfile: clientProfile,
									context: coreDataManager.mainContext)
		case (let x) where x is LawyerProfile:
			guard let lawyerProfile = profile as? LawyerProfile else { return }
			_ = LawyerProfileObject(lawyerProfile: lawyerProfile,
									context: coreDataManager.mainContext)
		default:
			break
		}
		
		coreDataManager.saveContext(synchronously: true)
	}
	
	func getLawyerProfile(by email: String) -> LawyerProfile? {
		let profiles = coreDataManager.fetchObjects(entity: LawyerProfileObject.self,
													predicate: NSPredicate(format: "email = %@", email),
													context: coreDataManager.mainContext)
		guard let profileObject = profiles.first else { return nil }
		return LawyerProfile(lawyerProfileObject: profileObject)
	}
	
	func getClientProfile(by email: String) -> ClientProfile? {
		let profiles = coreDataManager.fetchObjects(entity: ClientProfileObject.self,
													predicate: NSPredicate(format: "email = %@", email),
													context: coreDataManager.mainContext)
		guard let profileObject = profiles.first else { return nil }
		return ClientProfile(clientProfileObject: profileObject)
	}
	
	func getCurrenClientProfile() -> ClientProfile? {
		let profiles = coreDataManager.fetchObjects(entity: ClientProfileObject.self,
													context: coreDataManager.mainContext)
		guard let profileObject = profiles.first else { return nil }
		return ClientProfile(clientProfileObject: profileObject)
	}
}
