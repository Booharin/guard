//
//  LawyerProfileObject+CoreDataProperties.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//
//

//import Foundation
//import CoreData
//
//
//extension LawyerProfileObject {
//	
//	convenience init(lawyerProfile: LawyerProfile, context: NSManagedObjectContext) {
//		let entity = NSEntityDescription.entity(forEntityName: "LawyerProfileObject", in: context)!
//		self.init(entity: entity, insertInto: context)
//		self.city = lawyerProfile.city
//		self.country = lawyerProfile.country
//		self.email = lawyerProfile.email
//		self.firstName = lawyerProfile.firstName
//		self.id = Int64(lawyerProfile.id)
//		self.lastName = lawyerProfile.lastName
//		self.phone = lawyerProfile.phone
//		self.photo = lawyerProfile.photo
//		self.rate = lawyerProfile.rate
//		self.issueTypes = lawyerProfile.issueTypes
//		self.dateCreated = Int64(lawyerProfile.dateCreated)
//	}
//	
//	@nonobjc public class func fetchRequest() -> NSFetchRequest<LawyerProfileObject> {
//		return NSFetchRequest<LawyerProfileObject>(entityName: "LawyerProfileObject")
//	}
//	
//	@NSManaged public var city: String?
//	@NSManaged public var country: String?
//	@NSManaged public var email: String?
//	@NSManaged public var firstName: String?
//	@NSManaged public var id: Int64
//	@NSManaged public var lastName: String?
//	@NSManaged public var phone: String?
//	@NSManaged public var photo: String?
//	@NSManaged public var rate: Double
//	@NSManaged public var issueTypes: [String]
//	@NSManaged public var dateCreated: Int64
//	
//}
//
//extension LawyerProfileObject : Identifiable {
//	
//}
