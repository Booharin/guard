//
//  UserProfileObject+CoreDataProperties.swift
//  Guard
//
//  Created by Alexandr Bukharin on 22.07.2021.
//  Copyright © 2021 ds. All rights reserved.
//
//

import Foundation
import CoreData

extension UserProfileObject {

	convenience init(userProfile: UserProfile, context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "UserProfileObject", in: context)!
		self.init(entity: entity, insertInto: context)

		self.firstName = userProfile.firstName
		self.id = Int64(userProfile.id)
		self.lastName = userProfile.lastName
		self.photo = userProfile.photo
		self.cityCode = userProfile.cityCode
		self.countryCode = userProfile.countryCode
		self.dateCreated = userProfile.dateCreated
		self.averageRate = userProfile.averageRate ?? 0
		self.role = userProfile.role
		self.subIssueCodes = userProfile.subIssueCodes
		self.complaint = Int64(userProfile.complaint ?? 0)
		self.isAnonymus = userProfile.isAnonymus ?? true
	}

	@nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfileObject> {
		return NSFetchRequest<UserProfileObject>(entityName: "UserProfileObject")
	}

	@NSManaged public var averageRate: Double
	@NSManaged public var cityCode: [Int]?
	@NSManaged public var complaint: Int64
	@NSManaged public var countryCode: [Int]?
	@NSManaged public var dateCreated: String?
	@NSManaged public var firstName: String?
	@NSManaged public var id: Int64
	@NSManaged public var lastName: String?
	@NSManaged public var photo: String?
	@NSManaged public var role: String?
	@NSManaged public var subIssueCodes: [Int]?
	@NSManaged public var isAnonymus: Bool
}

extension UserProfileObject : Identifiable {
	
}
