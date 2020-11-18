//
//  UserProfileObject+CoreDataProperties.swift
//  Guard
//
//  Created by Alexandr Bukharin on 18.11.2020.
//  Copyright © 2020 ds. All rights reserved.
//
//

import Foundation
import CoreData


extension UserProfileObject {

	convenience init(userProfile: UserProfile, context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "UserProfileObject", in: context)!
		self.init(entity: entity, insertInto: context)

		self.email = userProfile.email
		self.firstName = userProfile.firstName
		self.id = Int64(userProfile.id)
		self.lastName = userProfile.lastName
		self.phoneNumber = userProfile.phoneNumber
		self.password = userProfile.password
		self.photo = userProfile.photo
		self.cityCode = Int64(userProfile.cityCode)
		self.countryCode = Int64(userProfile.countryCode)
		self.dateCreated = userProfile.dateCreated
		self.averageRate = userProfile.averageRate ?? 0
		self.role = userProfile.role
		self.isPhoneVisible = userProfile.isPhoneVisible ?? false
		self.isEmailVisible = userProfile.isEmailVisible ?? false
		self.isChatEnabled = userProfile.isChatEnabled ?? false
		self.issueTypes = userProfile.issueTypes
	}

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfileObject> {
        return NSFetchRequest<UserProfileObject>(entityName: "UserProfileObject")
    }

    @NSManaged public var averageRate: Double
    @NSManaged public var cityCode: Int64
    @NSManaged public var countryCode: Int64
    @NSManaged public var dateCreated: String?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: Int64
    @NSManaged public var isChatEnabled: Bool
    @NSManaged public var isEmailVisible: Bool
    @NSManaged public var isPhoneVisible: Bool
    @NSManaged public var lastName: String?
    @NSManaged public var password: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var photo: String?
    @NSManaged public var role: String?
    @NSManaged public var issueTypes: [String]?

}

extension UserProfileObject : Identifiable {

}
