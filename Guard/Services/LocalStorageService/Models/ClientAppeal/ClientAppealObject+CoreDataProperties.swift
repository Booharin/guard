//
//  ClientAppealObject+CoreDataProperties.swift
//  Guard
//
//  Created by Alexandr Bukharin on 04.02.2021.
//  Copyright © 2021 ds. All rights reserved.
//
//

import Foundation
import CoreData


extension ClientAppealObject {
	
	convenience init(clientAppeal: ClientAppeal, context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "ClientAppealObject", in: context)!
		self.init(entity: entity, insertInto: context)
		
		self.appealDescription = clientAppeal.appealDescription
		self.subIssueCode = Int64(clientAppeal.subIssueCode)
		self.title = clientAppeal.title
		self.id = Int64(clientAppeal.id)
		self.dateCreated = clientAppeal.dateCreated
		self.clientId = Int64(clientAppeal.clientId)
		self.cityTitle = clientAppeal.cityTitle
		self.lawyerChoosed = clientAppeal.lawyerChoosed ?? false
		self.cityCode = Int64(clientAppeal.cityCode ?? 0)
	}
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<ClientAppealObject> {
		return NSFetchRequest<ClientAppealObject>(entityName: "ClientAppealObject")
	}
	
	@NSManaged public var appealDescription: String?
	@NSManaged public var cityTitle: String?
	@NSManaged public var clientId: Int64
	@NSManaged public var dateCreated: String?
	@NSManaged public var id: Int64
	@NSManaged public var lawyerChoosed: Bool
	@NSManaged public var subIssueCode: Int64
	@NSManaged public var title: String?
	@NSManaged public var cityCode: Int64
	
}

extension ClientAppealObject : Identifiable {

}
