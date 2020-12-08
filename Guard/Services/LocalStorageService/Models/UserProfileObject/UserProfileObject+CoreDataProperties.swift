//
//  UserProfileObject+CoreDataProperties.swift
//  Guard
//
//  Created by Alexandr Bukharin on 08.12.2020.
//  Copyright © 2020 ds. All rights reserved.
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
			self.issueTypes = userProfile.issueCodes
		}

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfileObject> {
        return NSFetchRequest<UserProfileObject>(entityName: "UserProfileObject")
    }

    @NSManaged public var averageRate: Double
    @NSManaged public var cityCode: [Int]?
    @NSManaged public var countryCode: [Int]?
    @NSManaged public var dateCreated: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: Int64
    @NSManaged public var issueTypes: [Int]?
    @NSManaged public var lastName: String?
    @NSManaged public var photo: String?
    @NSManaged public var role: String?

}

extension UserProfileObject : Identifiable {

}
