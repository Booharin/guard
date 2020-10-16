//
//  ClientProfileObject+CoreDataProperties.swift
//  Guard
//
//  Created by Alexandr Bukharin on 15.10.2020.
//  Copyright © 2020 ds. All rights reserved.
//
//

import Foundation
import CoreData


extension ClientProfileObject {
	
	convenience init(clientProfile: ClientProfile, context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "ClientProfileObject", in: context)!
		self.init(entity: entity, insertInto: context)
		self.city = clientProfile.city
		self.country = clientProfile.country
		self.email = clientProfile.email
		self.firstName = clientProfile.firstName
		self.id = Int64(clientProfile.id)
		self.lastName = clientProfile.lastName
		self.phone = clientProfile.phone
		self.photo = clientProfile.photo
		self.rate = clientProfile.rate
		self.dateCreated = Int64(clientProfile.dateCreated)
	}
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<ClientProfileObject> {
		return NSFetchRequest<ClientProfileObject>(entityName: "ClientProfileObject")
	}
	
	@NSManaged public var dateCreated: Int64
	@NSManaged public var city: String?
	@NSManaged public var country: String?
	@NSManaged public var email: String?
	@NSManaged public var firstName: String?
	@NSManaged public var id: Int64
	@NSManaged public var lastName: String?
	@NSManaged public var phone: String?
	@NSManaged public var photo: String?
	@NSManaged public var rate: Double
	
}

extension ClientProfileObject : Identifiable {
	
}
